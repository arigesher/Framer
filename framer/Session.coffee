{_}          = require "./Underscore"
{Config}     = require "./Config"
{DeviceView} = require "./Device"

Utils = require "./Utils"

module.exports = do ->
  api = {}

  device = null
  layers = null
  layerRoot = null

  init = ->
    layers = []
    api._RootElement = layerRoot = createRootElement()
    api

  api.new = (deviceName) ->

    Utils.domComplete ->
      document.body.appendChild layerRoot

    device = new DeviceView()
    device.showKeyboard false
    device.setDevice deviceName if deviceName?

    api._RootElement = device.element()
    layers = []

    api


  api.reset = ->
    # Reset the print console layer
    api.printLayer = null

    # Remove all the listeners so we don't leak memory
    for layer in layers ? []
      layer.removeAllListeners()
    layers = []

    for delayTimer in api._delayTimers ? []
      clearTimeout delayTimer
    api._delayTimers = []

    for delayInterval in api._delayIntervals ? []
      clearInterval delayInterval
    api._delayIntervals = []

  api._registerLayer = (layer) ->
    layers.push layer

  api._unregisterLayer = (layer) ->
    layers = _.without layers, layer

  api._LayerList = ->
    _.clone layers

  api._siblings = (layer) ->
    _.filter layers, (other) ->
      other isnt layer and other.superLayer is null

  createRootElement = ->
    element = document.createElement "div"
    element.id = "FramerRoot"
    _.extend element.style, Config.rootBaseCSS
    element

  init()


