graphWidth = 1200
graphHeight = 800
dotSize = 3
graphMarginLeft = 50
graphMarginRight = 50
graphMarginTop = 50
graphMarginBottom = 50

title = "Curves and Bonds"

data = []
curves = []

drawGraph = (xMin, xMax, yMin, yMax) =>

  console.log("---> Start")
  startTime = new Date()

  chart = new suthchart.Chart(graphWidth, graphHeight)

  window.mydata   = data # to aid debugging
  window.mycurves = curves # to aid debugging
  
  pointsx    = _.map(data, (d) -> parseFloat(d[7]))
  pointsy    = _.map(data, (d) -> parseFloat(d[9]))
  pointsdata = _.map(data, (d) -> d[0])

  chart.margins(graphMarginTop, graphMarginRight, graphMarginBottom, graphMarginLeft)
  chart.linearXAxis("Years to maturity", xMin, xMax)
  chart.linearYAxis("Yield", yMin, yMax)

  # Curves
  curveGroup = chart.group("curves")
  _.each(curves, (curve,key) ->
    range = _.range(0, curve.length-1, 4)
    points = _.map(range, (i) ->
      [chart.sx(curve[i].yearsToMaturity), chart.sy(curve[i].yield)]
    )
    curveGroup.add(chart.curve(points).withStroke(0.5, 'red'))
  )
  chart.add(curveGroup)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
  # Points
  pointGroup = chart.group("points")
  for p,i in pointsx
    c = pointGroup.add(chart.circle(chart.sx(pointsx[i]), chart.sy(pointsy[i]), dotSize).withStroke(1, 'black').withFill('#888').withOpacity(0.5).withID(i))
  chart.add(pointGroup)

  chart.add(chart.mask(1.0))

  chart.add(chart.title("Curves and Bonds"))
  chart.add(chart.grid())
  chart.add(chart.axis())

  # Highlighted bond
  chart.add(chart.circle(0,0, dotSize*1.5).withStroke(1, 'white').withFill('red').withOpacity(1).withID('highlighted-bond').hidden())

  # Create a single manual popup for testing...
  popupX      = 640
  popupY      = 515
  popupWidth  = 200
  popupHeight = 35
  popupGroup  = chart.group("popup",popupX,popupY).hidden()
  popupGroup.add(chart.rectangle(1,1,popupWidth + 1,popupHeight + 1,5,5).withStrokeWidth(0).withFillColor('black').withOpacity(0.1))
  popupGroup.add(chart.rectangle(0,0,popupWidth,popupHeight,5,5).withFillColor('black').withOpacity(0.75))
  popupGroup.add(chart.text(5,10, "XX012345678").withFont('arial', 12).withStrokeColor('white').withAnchoring('start').withOpacity(0.75))
  popupGroup.add(chart.text(5, 25, "Royal Bank of Scotland").withFont('arial', 12).withStrokeColor('white').withAnchoring('start').withFontWeight('bold').withOpacity(0.75))
  chart.add(popupGroup)

  # Drag zoom
  chart.enableZoom($('#graph')[0], drawGraph)

  endTime = new Date()
  console.log("Time to construct graph object: #{endTime - startTime}")

  document.getElementById('graph').innerHTML = chart.render()

  renderEndTime = new Date()
  console.log("Time to render graph: #{renderEndTime - endTime}")

  test = $('#graph')

  domProcessingEndTime = new Date()
  console.log("Time for browser to complete rendering the DOM: #{domProcessingEndTime - renderEndTime}")

  # console.log(chart.render())
  # console.log(chart)

  highlightedBondElement = chart.activeElement($('.sd-circle[data-id="highlighted-bond"]')[0])

  deselect = (chart) ->
    selected = $('.sd-circle.selected')[0]
    if selected?
      olde = chart.activeElement(selected)
      olde.removeClass('selected')
      highlightedBondElement.hide()

  $('#graph').on('click', '.sd-circle', (event) ->
    e = chart.activeElement(this)
    deselect(chart)
    position = e.getPosition()
    x = position.left
    y = position.top
    highlightedBondElement.setPosition(x,y).show()
    e.addClass('selected')
    i = e.id
    # console.log("clicked on bond #{data[i][0]} issued by #{data[i][2]}")
    false
  )

  $('#graph').on('mouseenter mouseleave', '.sd-circle', (event) =>
    e = chart.activeElement(event.target)
    i = if (e.id == 'highlighted-bond')
      selected = $('.sd-circle.selected')[0]
      chart.activeElement(selected).id
    else e.id
    popupElement = $('.sd-group[data-id="popup"]')[0]
    popup        = chart.activeElement(popupElement)
    if (event.type == 'mouseenter')
      p = e.getPosition()
      if graphWidth - p.left - popupWidth > 0
        popup.setPosition(p.left + 10, p.top - popupHeight - 10)
      else
        popup.setPosition(p.left - 10 - popupWidth, p.top - popupHeight - 10)
      chart.activeElement($(popupElement).find('.sd-text')[0]).setText(data[i][0])
      chart.activeElement($(popupElement).find('.sd-text')[1]).setText(data[i][2])
      popup.show()
    else
      e = chart.activeElement(event.target)
      popupElement = $('.sd-group[data-id="popup"]')[0]
      popup        = chart.activeElement(popupElement)
      popup.hide()
  )

  $('.sd-group[data-id="popup"]').on('click', (event) ->
    console.log("Clicked on popup")
  )

  $('#graph').on('click', (event) ->
    deselect(chart)
  )

  jQueryEndTime = new Date()
  console.log("Time to set up jQuery event handling: #{jQueryEndTime - domProcessingEndTime}")


downloadCount = 2
$.getJSON("../data/2012-05-22.json", (d) ->
  data = d.data
  downloadCount -= 1
  if downloadCount == 0 then drawGraph(0,50,0,30)
)
$.getJSON("../data/curves-2012-05-29.json", (d) ->
  curves = d
  downloadCount -= 1
  if downloadCount == 0 then drawGraph(0,50,0,30)
)

