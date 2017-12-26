App.buckets = {}

App.buckets['share'] = App.buckets['show'] = ->
  App.buckets.initializeAce()
  RequestCountPoller.start()

  tipsyConfig = title: 'Copy to Clipboard', copiedHint: 'Copied!'

  $copyButton = $('#copy-button')
  $copyButton.tipsy(gravity: $.fn.tipsy.autoNS)
  $copyButton.attr('title', tipsyConfig.title)

  clipboard = new Clipboard('#copy-button')
  clipboard.on 'success', ->
    $copyButton.prop('title', tipsyConfig.copiedHint).tipsy('show')
    $copyButton.attr('original-title', tipsyConfig.title)

App.buckets.initializeAce = ->
  autoResizeAce = ->
    # http://stackoverflow.com/questions/11584061/
    newHeight = editor.getSession().getScreenLength() * editor.renderer.lineHeight + editor.renderer.scrollBar.getWidth()

    newHeight = 150 if newHeight < 150

    $('#editor').height "#{newHeight}px"
    $('#editor-section').height "#{newHeight}x"

    # This call is required for the editor to fix all of
    # its inner structure for adapting to a change in size
    editor.resize()

  $('#putsreq-url-input').on 'click', -> $(this).select()

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
    favicon = new Favico(bgColor: '#6C92C8', animation: 'none')
    favicon.badge($('#bucket-request-count').text())

    bucket = $('#putsreq-url-input').data('bucket-token')

    pusher = new Pusher('3466d56fe2ef1fdd2943')
    channel = pusher.subscribe("channel_requests_#{bucket}")
    channel.bind 'new', (data) ->
      console.log(data)
      localStorage.setItem(data.id, data)
      try
        $('#bucket-request-count').text(data.count)

        favicon.badge(data.count)
      catch error

      $('#new-requests-info').hide().
        html('<em><a id="new-requests-received" href="javascript:window.location.reload();">New requests found. Load newer requests?</a></em>').fadeIn('slow')
