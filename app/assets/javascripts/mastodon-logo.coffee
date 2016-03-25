defaultClass = 'mastodon-shape'
pieces = [
  'path#mastodon-tusk-front, path#mastodon-tusk-back',
  'path#mastodon-nose',
  'path#mastodon-cheek',
  'path#mastodon-forehead',
  'path#mastodon-backhead',
  'path#mastodon-ear',
]
pieceIndex = 0
firstPiece = pieces[0]

currentTimer = null
delay        = 100
runs         = 0
stop_at_run  = 1

clearHighlights = ->
  $(".#{defaultClass}.highlight").attr('class', defaultClass)

start = ->
  clearHighlights()
  pieceIndex = 0
  runs = 0
  pieces.reverse() unless pieces[0] == firstPiece
  clearInterval(currentTimer) if currentTimer
  currentTimer = setInterval(work, delay)

stop = ->
  clearInterval(currentTimer)
  clearHighlights()

work = ->
  clearHighlights()
  $(pieces[pieceIndex]).attr('class', "#{defaultClass} highlight")

  if pieceIndex == pieces.length - 1
    pieceIndex = 0
    pieces.reverse()
    runs++
  else
    pieceIndex++

  if runs == stop_at_run
    stop()

$(document).on 'turbolinks:load', ->
  setTimeout(start, 100)
