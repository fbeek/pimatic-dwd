$(document).on( "templateinit", (event) ->

  class DwdInfoDisplayDeviceItem extends pimatic.DeviceItem
    constructor: (templData, @device) ->
      super(templData, @device)
      @warningLevel = @device.config.warningLevel

      @warningLevelLabelAttr = @getAttribute("warningLevelLabel")
      @jsonDataWarningsAttr = @getAttribute("jsonDataWarnings")
      @jsonDataNotificationsAttr = @getAttribute("jsonDataNotifications")

      @jsonDataWarnings = ko.observable()
      @jsonDataNotifications = ko.observable()
      @warningLevelLabel = ko.observable()

      @updateJsonDataWarnings(@jsonDataWarningsAttr.value())
      @updateJsonDataNotifications(@jsonDataNotificationsAttr.value())
      @warningLevelLabel(@warningLevelLabelAttr.value())

      @jsonDataWarningsAttr.value.subscribe (newJsonData) =>
        @updateJsonDataWarnings(newJsonData)

      @jsonDataNotificationsAttr.value.subscribe (newJsonData) =>
        @updateJsonDataNotifications(newJsonData)

      @warningLevelLabelAttr.value.subscribe (newData) =>
        @warningLevelLabel(newData)

    updateJsonDataWarnings: (data) =>
      try
        json = JSON.parse(data)
        @jsonDataWarnings(json)
      catch error
        console.log('pimatic-dwd : error while parsing warnings json')
        console.log(error)

    updateJsonDataNotifications: (data) =>
      try
        json = JSON.parse(data)
        @jsonDataNotifications(json)
      catch error
        console.log('pimatic-dwd : error while parsing notifications json')
        console.log(error)

  pimatic.templateClasses['dwd-info-display-device'] = DwdInfoDisplayDeviceItem
)