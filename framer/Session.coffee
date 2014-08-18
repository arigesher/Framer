{_}        = require "./Underscore"
{Config}   = require "./Config"
DeviceView = require "./Device"

module.exports = do ->
  api = {}

  device = null
  layers = null

  init = ->
    layers = []
    api._RootElement = createRootElement()

    api

  api.new = (deviceName) ->
    init()
    device = new DeviceView()
    device.showKeyboard false
    device.setDevice deviceName if deviceName?

    api._RootElement = device._element
    layers = []
    api

  api.reset = ->
    # There is no use calling this even before the dom is ready
    if __domReady is false
      return

    # Reset all pending operations to the dom
    __domComplete = []

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

  api._layerList = ->
    _.clone layers

  api._siblings = (layer) ->
    _.filter layers, (other) ->
      other isnt layer and other.superLayer is null

  createRootElement = ->
    element = document.createElement "div"
    element.id = "FramerRoot"
    _.extend element.style, Config.rootBaseCSS
    document.body.appendChild element
    element

  api


