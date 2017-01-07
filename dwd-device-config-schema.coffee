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
        description: "Regional zone to show warnings from"
        type: "string"
        default: ""
      warningLevel:
        description: "Level of warning to be displayed"
        type: "string"
        default: ""
    }
  }
}
