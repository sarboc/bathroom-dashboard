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
    @set('day', today.toLocaleDateString("en-US", {weekday: 'long'}))
    @set('date', today.toLocaleDateString("en-US", {month: "short", day: "numeric"}))

  formatTime: (i) ->
    if i < 10 then "0" + i else i