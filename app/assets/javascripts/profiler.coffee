$ ->
  $(document).on 'turbolinks:load', ->
    unless typeof window.MiniProfiler == 'undefined'
      window.MiniProfiler.init()
      window.MiniProfiler.pageTransition()
