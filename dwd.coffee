module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class Dwd extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      console.log(config)
      env.logger.info("Hello World")

  Dwd = new Dwd
  return Dwd