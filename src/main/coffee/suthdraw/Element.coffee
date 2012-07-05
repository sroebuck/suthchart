class Element

  constructor: ->

  withStroke: (@strokeWidth, @strokeColor) -> @

  withFill: (@fillColor) -> @

  withStrokeWidth: (@strokeWidth) -> @

  withStrokeColor: (@strokeColor) -> @

  withFillColor: (@fillColor) -> @

  withOpacity: (@opacity) -> @

  withCrispEdges: (@crispEdges = true) -> @

  withRotation: (@rotationAngle) -> @

  withID: (@id) -> @

  idIfSet: () ->
    if (@id == "") then "" else "data-id=\"#{@id}\""

window.suthdraw ?= {}
window.suthdraw.Element = Element
