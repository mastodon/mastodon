$(document).on 'turbolinks:load', ->
  window.MiniProfiler.pageTransition() unless typeof window.MiniProfiler == 'undefined'
