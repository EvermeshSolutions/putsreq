window.App = {}

# We need it to load Ace editor workers. Otherwise it will fail with assets pipeline.
ace.config.set('workerPath', '/javascripts/vendor/ace/')
ace.config.set('themePath',  '/javascripts/vendor/ace/')

$ ->
  # https://github.com/fnando/dispatcher-js
  Dispatcher.run App, $('body').data('route')
