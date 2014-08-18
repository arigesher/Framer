{_}      = require "./Underscore"
{Config} = require "./Config"

module.exports = do ->
  api = {}

  layers = []

  init = ->
    api._RootElement = createRootElement()

    layers = []
    api

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

  init()


