"""

Todo:

- Status bar (light and dark style)
- Alert throwing
- Phone rotation


API:

DeviceView({
  scale: null|0.5,
  padding: 50
  keyboardAnimationCurve: "spring(400,40,0)"
})

DeviceView.setDevice(deviceName|deviceInfo)
DeviceView.showKeyboard()
DeviceView.hideKeyboard()
DeviceView.toggleKeyboard()


"""

Utils = require "./Utils"
{_}   = require "./Underscore"

DeviceViewHostedImagesUrl = ""
DeviceViewDefaultDevice = "iphone-5s–spacegray"

{BaseClass} = require "./BaseClass"
{Layer}     = require "./Layer"

class exports.DeviceView extends BaseClass

  constructor: (options={}) ->

    defaults = _.extend Devices[DeviceViewDefaultDevice],
      scale: null
      padding: 50
      orientation: 0
      keyboardAnimationCurve: "spring(400,40,0)"

    @setup()

    _.extend @, Utils.setDefaultProperties options, defaults

    @setDevice @

    Screen.on "resize", @update

  setup: ->
    @background = new Layer
    @background.backgroundColor = "white"

    @phone = new Layer

    @screen   = new Layer superLayer:@phone
    @viewport = new Layer superLayer:@screen
    @content  = new Layer superLayer:@viewport

    @screen.backgroundColor = "white"
    @viewport.backgroundColor = "white"
    @content.backgroundColor = "white"

    @content.originX = 0
    @content.originY = 0

    @keyboard = new Layer superLayer:@viewport
    @keyboard.on "click", @toggleKeyboard

  update: =>
    @background.width  = Screen.width
    @background.height = Screen.height

    @phone.scale = @_calculatePhoneScale()
    @phone.center()

    [width, height] = @_getDimensions(@screenWidth, @screenHeight)

    @screen.width  = @screenWidth
    @screen.height = @screenHeight

    @viewport.width  = @content.width  = width
    @viewport.height = @content.height = height
    @screen.center()

  setDevice: (device) ->
    if _.isString device

      if not Devices.hasOwnProperty device.toLowerCase()
        throw Error "No device named #{device}. Options are: #{_.keys Devices}"

      device = Devices[device.toLowerCase()]

    _.extend @, device

    @phone.image  = deviceImageUrl device.deviceImage
    @phone.width  = device.deviceImageWidth
    @phone.height = device.deviceImageHeight

    @_renderKeyboard()
    @hideKeyboard false

    @update()

  element: ->
    @phone._element

  _calculatePhoneScale: ->
    # If a scale was given we use that
    return @scale if @scale

    [width, height] = @_getDimensions(@phone.width, @phone.height)

    phoneScale = _.min [
      (Screen.width -  (@padding * 2)) / width,
      (Screen.height - (@padding * 2)) / height
    ]


    phoneScale

  # phone rotation

  rotateLeft: ->
    return if @orientation == 90
    @_changeOrientation(@orientation + 90)

  rotateRight: ->
    return if @orientation == -90
    @_changeOrientation(@orientation - 90)

  # todo: break up
  _changeOrientation: (newOrientation) ->
    return unless [0, -90, 90].indexOf(newOrientation) > -1

    @orientation = newOrientation

    # get new phone props
    phoneProperties =
      rotationZ: newOrientation
      scale: @_calculatePhoneScale()

    # calculate new content frame
    [width, height] = @_getDimensions(@screenWidth, @screenHeight)
    [x, y] = [(@screen.width - width) / 2, (@screen.height - height) / 2]

    contentProperties =
      rotationZ: -newOrientation
      width:  width
      height: height
      x: x
      y: y

    @keyboard.visible = false
    @_renderKeyboard()
    @_animateKeyboard false, 2*height # some parts might be visible during rotation

    animationCurve = "spring(400,40,0)"
    @phone.animateStop()
    @viewport.animateStop()

    @phone.animate properties: phoneProperties, curve: animationCurve
    @viewport.animate(properties: contentProperties, curve: animationCurve)

    @keyboard.visible = true
    @_animateKeyboard true, height - @keyboard.height if @_keyboardVisible


  _getDimensions: (width, height) ->
    if Math.abs(@orientation) == 90 then [height, width] else [width, height]


  # Keyboard

  showKeyboard: (animate=true) ->
    @_animateKeyboard animate, @viewport.height - @keyboard.height
    @_keyboardVisible = true
    @emit "change:keyboard", true

  hideKeyboard: (animate) ->
    @_animateKeyboard animate, @viewport.height
    @_keyboardVisible = false
    @emit "change:keyboard", false

  toggleKeyboard: (animate) =>
    if @_keyboardVisible is true
      @hideKeyboard animate
    else
      @showKeyboard animate

  _renderKeyboard:  ->
    orientation = if Math.abs(@orientation) == 90 then 'landscape' else 'portrait'

    @keyboard.image  =  deviceImageUrl @keyboards[orientation].image
    @keyboard.width  =  @keyboards[orientation].width
    @keyboard.height =  @keyboards[orientation].height

  _animateKeyboard: (animate, keyboardY) ->
    @keyboard.bringToFront()
    if animate is false
      @keyboard.y = keyboardY
    else
      @keyboard.animate
        properties: {y:keyboardY}
        curve: @keyboardAnimationCurve

  # zooming

  setZoomLevel: (level, animate = true) ->
    if level == 'fit'
      scale = @_calculatePhoneScale()
    else
      scale = level

    return if scale == @phone.scale
    @phone.animateStop()

    unless animate == true
      @phone.scale = scale
      return @phone.center()

    @phone.animate
      properties: { scale: scale }
      curve: "spring(400,40,0)"

  setContentScale: (scale) ->
    return if scale == @content.scale
    @content.scale = scale


iPhone5BaseDevice =
  deviceImageWidth: 792
  deviceImageHeight: 1632
  screenWidth: 640
  screenHeight: 1136
  keyboards:
    portrait:
      image:  "ios-keyboard.png"
      width: 640
      height: 432
    landscape:
      image: "ios-keyboard-landscape-light.png"
      width: 1136
      height: 322

iPadMiniBaseDevice =
  deviceImageWidth: 920
  deviceImageHeight: 1328
  screenWidth: 768
  screenHeight: 1024
  keyboardImage: "ios-keyboard.png"
  keyboardWidth: 768
  keyboardHeight: 432

iPadAirBaseDevice =
  deviceImageWidth: 1856
  deviceImageHeight: 2584
  screenWidth: 1536
  screenHeight: 2048
  keyboardImage: "ios-keyboard.png"
  keyboardWidth: 0
  keyboardHeight: 0


Devices =

  # iPhone 5S
  "iphone-5s–spacegray": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5S Space Gray"
    deviceImage: "iphone-5S–spacegray.png"
  "iphone-5s–silver": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5S Silver"
    deviceImage: "iphone-5S–silver.png"
  "iphone-5s–gold": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5S Gold"
    deviceImage: "iphone-5S–gold.png"

  # iPhone 5C
  "iphone-5c–green": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5S Green"
    deviceImage: "iphone-5C–green.png"
  "iphone-5c–blue": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5S Blue"
    deviceImage: "iphone-5C–blue.png"
  "iphone-5c–yellow": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5S Yellow"
    deviceImage: "iphone-5C–yellow.png"
  "iphone-5c–pink": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5C Pink"
    deviceImage: "iphone-5C-pink.png"
  "iphone-5c–white": _.extend {}, iPhone5BaseDevice,
    name: "iPhone 5C White"
    deviceImage: "iphone-5C-white.png"

  # iPad Mini
  "ipad-mini-silver": _.extend {}, iPadMiniBaseDevice,
    name: "iPad Mini Silver"
    deviceImage: "ipad-mini-silver.png"
  "ipad-mini-spacegray": _.extend {}, iPadMiniBaseDevice,
    name: "iPad Mini Space Gray"
    deviceImage: "ipad-mini-spacegray.png"

deviceImageUrl = (name) ->
  # TODO: correct url here
  return "http://cdn.#{name}" unless FramerStudio?
  FramerStudio.resourcePath name


  # iPad Air
#   "ipad-air-silver": _.extend {}, iPadAirBaseDevice,
#     name: "iPad Mini Silver"
#     deviceImage: "ipad-mini-silver.png"
#   "ipad-air-spacegray": _.extend {}, iPadAirBaseDevice,
#     name: "iPad Mini Space Gray"
#     deviceImage: "ipad-mini-spacegray.png"


# @{
#     @"name": @"iPad Mini Silver",
#     @"width": @(768), @"height": @(1024),
#     @"imageName": @"ipad-mini-silver", @"imageFactor": @(1.0)},
# @{
#     @"name": @"iPad Mini Space Gray",
#     @"width": @(768), @"height": @(1024),
#     @"imageName": @"ipad-mini-spacegray", @"imageFactor": @(1.0)},
# @{
#     @"name": @"iPad Air Silver",
#     @"width": @(1536), @"height": @(2048),
#     @"imageName": @"ipad-air-silver", @"imageFactor": @(1.0)},
# @{
#     @"name": @"iPad Air Space Gray",
#     @"width": @(1536), @"height": @(2048),
#     @"imageName": @"ipad-air-spacegray", @"imageFactor": @(1.0)},
# @{
#     @"name": @"Nexus 5",
#     @"width": @(1080), @"height": @(1920),
#     @"imageName": @"lg-nexus-5", @"imageFactor": @(1.0)},
# ];
