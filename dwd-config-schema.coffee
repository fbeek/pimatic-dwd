module.exports = {
  title: "Configuration Options for the pimatic-dwd plugin"
  type: "object"
  properties:
    url:
      description: "URL to the DWD warnings.json file"
      type: "string"
      default: "http://www.dwd.de/DWD/warnungen/warnapp/json/"
    updateInterval:
      description: "update interval for the json data in minutes"
      type: "number"
      default: 10
    filename:
      description: "name of the json file on the server"
      type: "string"
      default: "warnings.json"
    debug:
      doc: "Enabled debug messages"
      type: "boolean"
      default: false
}
