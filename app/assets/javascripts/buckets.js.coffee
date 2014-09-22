App.buckets = {}

App.buckets['share'] = App.buckets['show'] = ->
  App.buckets.initializeAce()

  ZeroClipboard.config
    moviePath: '/flash/ZeroClipboard.swf'

  window.client = new ZeroClipboard $('#copy-button')
  htmlBridge = '#global-zeroclipboard-html-bridge'

  tipsyConfig = title: 'Copy to Clipboard', copiedHint: 'Copied!'

  $(htmlBridge).tipsy gravity: $.fn.tipsy.autoNS
  $(htmlBridge).attr 'title', tipsyConfig.title

  client.on 'complete', (client, args) ->
    $('#putsreq-url-input').focus().blur()

    $(htmlBridge).prop('title', tipsyConfig.copiedHint).tipsy 'show'
    $(htmlBridge).attr 'original-title', tipsyConfig.title

  RequestCountPoller.start()


App.buckets.initializeAce = ->
  autoResizeAce = ->
    # http://stackoverflow.com/questions/11584061/
    newHeight = editor.getSession().getScreenLength() * editor.renderer.lineHeight + editor.renderer.scrollBar.getWidth()

    $('#editor').height "#{newHeight}px"
    $('#editor-section').height "#{newHeight}x"

    # This call is required for the editor to fix all of
    # its inner structure for adapting to a change in size
    editor.resize()

  $('#putsreq-url-input').on 'click', ->
    $(this).select()

  editor = ace.edit 'editor'
  editor.setTheme 'ace/theme/monokai'
  editor.setShowPrintMargin(false)
  editor.getSession().setMode 'ace/mode/javascript'
  editor.getSession().on 'change', ->
    $('#bucket_response_builder').val editor.getSession().getValue()

  editor.setValue $('#response-builder-container').text()
  editor.clearSelection()

  # Set initial size to match initial content
  autoResizeAce()

  # Whenever a change happens inside the ACE editor, update
  # the size again
  editor.getSession().on 'change', autoResizeAce

RequestCountPoller =
  start: ->
    favicon = new Favico(animation:'fade', bgColor: '#6C92C8', animation: 'none')

    @updateCount(favicon)

    setInterval (=> @updateCount(favicon)), 60000

  updateCount: (favicon) ->
    $.get "#{$('#putsreq-url-input').val()}/requests/count", (data) ->
      favicon.badge(data)
      currentCount = $('#bucket-request-count').text()
      $('#bucket-request-count').text(data)

      if parseInt(data, 10) > parseInt(currentCount, 10) && $('#new-requests-info #new-requests-received').length == 0
        $('#new-requests-info').hide().
          append('<em><a id="new-requests-received" href="javascript:window.location.reload();">New requests received. Load newer requests?</a></em>').fadeIn('slow')
