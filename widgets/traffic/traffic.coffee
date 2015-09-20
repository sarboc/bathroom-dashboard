class Dashing.Traffic extends Dashing.Widget

  onData: (data) ->
    @setTime(data.sara_time, data.sean_time)

  setTime: (saraTime, seanTime) ->
    @set('sara-time', saraTime)
    @set('sean-time', seanTime)
