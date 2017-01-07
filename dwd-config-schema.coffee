module.exports = {
  title: "Configruation Options for the pimatic-dwd plugin"
  type: "object"
  properties:
    url:
      description: "URL to the DWD warnings.json file"
      type: "string"
      default: "http://www.dwd.de/DWD/warnungen/warnapp/json/warnings.json"
    updateInterval:
      description: "update interval for the json data in minutes"
      type: "integer"
      default: 10
}