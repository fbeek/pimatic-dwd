module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  jsonfile = require 'jsonfile'

  class DwdPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      env.logger.info("Starting DWD Plugin.")
      env.logger.info("Loading data from : " + @config.url + "every " + @config.updateInterval + "minutes")

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

    class DwdInfoDisplayDevice extends env.devices.Device
      @deviceType = "DwdInfoDisplayDevice"

      constructor: (@config,@plugin) ->
        super()

      destroy: ->
        super()

  dwdPlugin = new DwdPlugin
  return dwdPlugin