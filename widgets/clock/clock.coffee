class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    h = today.getHours()
    if h > 12
      h = h - 12
    m = today.getMinutes()
    m = @formatTime(m)
    @set('time', h + ":" + m)
    @set('date', today.toDateString())

  formatTime: (i) ->
    if i < 10 then "0" + i else i