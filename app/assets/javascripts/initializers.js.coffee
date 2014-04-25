window.App = {}

$ ->
  # https://github.com/fnando/dispatcher-js
  Dispatcher.run App, $('body').data('route')
