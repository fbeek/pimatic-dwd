module.exports = {
  title: "pimatic-dwd device config schemas"
  DwdInfoDisplayDevice:{
    title: "Config options for the DWD information display device"
    type: "object"
    properties: {
      id:
        description: "ID of the Device"
        type: "string"
        default: ""
      name:
        description: "Name of the Device"
        type: "string"
        default: ""
      zone:
        description: "Regional zone to show warnings from (WarnCellId from PDF under /pimatic-dwd/ZoneIds.pdf or the readme on Github https://github.com/fbeek/pimatic-dwd)"
        type: "string"
        default: ""
      warningLevel:
        description: "Level of warning to be displayed, the plugin will show all messages above this level"
        type: "string"
        default: "Minor"
        enum : ["Minor","Moderate","Severe","Extreme"]
    }
  }
}
