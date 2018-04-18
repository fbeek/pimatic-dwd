module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  Moment = env.require 'moment'
  rp = require 'request-promise'

  class DwdPlugin extends env.plugins.Plugin
    @client = null
    @intervalId = null

    init: (@app, @framework, @config) =>
      env.logger.info("Starting DWD Plugin.")
      env.logger.info("Loading data from : " + @config.url + @config.filename + " every " + @config.updateInterval + " minutes")
      
      deviceConfigDef = require("./dwd-device-config-schema")

      deviceTypeClasseNames = [
        DwdInfoDisplayDevice
      ]

      @availableDevices = []

      index = 0
      for DeviceClass in deviceTypeClasseNames
        do (DeviceClass) =>
          @framework.deviceManager.registerDeviceClass(DeviceClass.name, {
            configDef: deviceConfigDef[DeviceClass.name]
            createCallback: (deviceConfig,lastState) =>
              device = new DeviceClass(deviceConfig,this)
              index = index + 1
              @availableDevices.push device
              return device
          })

      # wait till all plugins are loaded
      @framework.on "after init", =>
        # Check if the mobile-frontent was loaded and get a instance
        mobileFrontend = @framework.pluginManager.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-dwd/app/js/dwd.coffee"
          mobileFrontend.registerAssetFile 'css', "pimatic-dwd/app/css/dwd.css"
          mobileFrontend.registerAssetFile 'html', "pimatic-dwd/app/views/dwd-info-display-device.html"
          env.logger.debug "templates loaded"
        else
          env.logger.warn "dwd could not find the mobile-frontend. No gui will be available"
      
      @receiveJsonFile(@config.url+@config.filename);

      @intervalId = setInterval(
        @receiveJsonFile
        , @config.updateInterval * 1000 * 60
        #, 60000
        , @config.url+@config.filename
      )

    receiveJsonFile: (path) =>
      options = 
        url: path

      rp(options)
        .then (parsedBody) =>
          env.logger.debug(parsedBody)
          parsedBody = parsedBody.replace('warnWetter.loadWarnings(','')
          parsedBody = parsedBody.substring(0, parsedBody.length - 2)
        .then (JSON.parse)  
        .then (data) =>
          env.logger.debug('Received and parsed new data from DWD')
          @emit('updatedDwdData',data)
        .catch (err) =>
          env.logger.info('Error while data parsing from DWD : ' + err) 

    class DwdInfoDisplayDevice extends env.devices.Device
      attributes:
        jsonDataWarnings:
          description: "DWD Data to display"
          type: "string"
          default: '[{"start":1484254800000,"end":1484305200000,"regionName":"","level":0,"type":9999,"altitudeStart":null,"event":"","headline":"","description":"","altitudeEnd":null,"stateShort":"","instruction":"","state":""}]'
        jsonDataNotifications:
          description: "DWD Data to display"
          type: "string"
          default: '[{"start":1484254800000,"end":1484305200000,"regionName":"","level":0,"type":9999,"altitudeStart":null,"event":"","headline":"","description":"","altitudeEnd":null,"stateShort":"","instruction":"","state":""}]'
        zone:
          description: "DWD Zone ID"
          type: "string"
        warningLevel:
          description: "Warning Level to display"
          type: "string"
        warningLevelLabel:
          description: "Warning Level Name to display"
          type: "string"

      @deviceType = "DwdInfoDisplayDevice"
      
      template: 'dwd-info-display-device'

      constructor: (@config,@plugin) ->
        @id = @config.id
        @name = @config.name
        @zone = @config.zone
        @warningLevel = @config.warningLevel
        @jsonDataWarnings = ""
        @jsonDataNotifications = ""

        @plugin.on('updatedDwdData',updatedDwdDataHandlder = (data) =>
          if data.hasOwnProperty("warnings") && typeof data.warnings == 'object'
            if data.warnings.hasOwnProperty(@zone)
              env.logger.debug("found warning data in json for device " + @id)
              dataset = data["warnings"][@zone]
              extract = []

              for d, i in dataset
                if d.level >= @getWarningLevelAsInt()
                  d.start = Moment.unix(d.start/1000).format("DD.MM.YYYY HH:mm")
                  d.end = Moment.unix(d.end/1000).format("DD.MM.YYYY HH:mm")
                  extract.push(d);

              @_setJsonDataWarnings(JSON.stringify(extract))
            else
              @_setJsonDataWarnings(JSON.stringify([]))
              env.logger.debug("no warning data in json for device " + @id)

          if data.hasOwnProperty("vorabInformation") && typeof data.vorabInformation == 'object'
            if data.vorabInformation.hasOwnProperty(@zone)
              env.logger.debug("found notification data in json for device " + @id)
              dataset = data["vorabInformation"][@zone]
              extract = []

              for d, i in dataset
                if d.level >= @getWarningLevelAsInt()
                  d.start = Moment.unix(d.start/1000).format("DD.MM.YYYY HH:mm")
                  d.end = Moment.unix(d.end/1000).format("DD.MM.YYYY HH:mm")
                  extract.push(d);

              @_setJsonDataNotifications(JSON.stringify(extract))
            else
              @_setJsonDataNotifications(JSON.stringify([]))
              env.logger.debug("no notification data in json for device " + @id)
        )

        @on('destroy', () =>
          @removeListener('updatedDwdData',updatedDwdDataHandlder)
        )

        super()

      getTemplateName: -> "dwd-info-display-device"
      getJsonDataWarnings: -> Promise.resolve(@jsonDataWarnings)
      getJsonDataNotifications: -> Promise.resolve(@jsonDataNotifications)
      getZone: -> Promise.resolve(@zone)
      getWarningLevel: -> Promise.resolve(@warningLevel)
      getWarningLevelLabel: -> Promise.resolve(@getWarningLevelLabel())

      getWarningLevelAsInt: =>
        switch @warningLevel
          when "Minor" then return 2
          when "Moderate" then return 3
          when "Severe" then return 4
          when "Extreme" then return 5
          else return 0

      getWarningLevelLabel: =>
        switch @warningLevel
          when "Minor" then return 'Wetterwarnungen oder stärker'
          when "Moderate" then return 'Warnungen vor markantem Wetter oder stärker'
          when "Severe" then return 'Unwetterwarnungen oder stärker'
          when "Extreme" then return 'Warnungen vor extremem Unwetter'
          else return ''

      _setJsonDataWarnings: (data) ->
        #if @jsonDataWarnings is data then return
        @jsonDataWarnings = data
        @emit 'jsonDataWarnings', data

      _setJsonDataNotifications : (data) ->
        #if @jsonDataNotifications is data then return
        @jsonDataNotifications = data
        @emit 'jsonDataNotifications', data
      
      destroy: ->
        super()

  dwdPlugin = new DwdPlugin
  return dwdPlugin
