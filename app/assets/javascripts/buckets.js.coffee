App.buckets = {}

App.buckets['show'] = ->
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

  ZeroClipboard.config
    moviePath: '/flash/ZeroClipboard.swf'

  client = new ZeroClipboard($('.clipboard'))
  htmlBridge = '.global-zeroclipboard-container'
  $(htmlBridge).tipsy gravity: $.fn.tipsy.autoNS
  tipsyConfig = title: '', copiedHint: 'Copied!'

  $('.clipboard').on 'mouseover', (e) ->
    if e.currentTarget.id == 'copy-button'
      tipsyConfig.title = 'Copy Bucket'
    else
      tipsyConfig.title = 'Share Bucket'

    $(htmlBridge).attr 'original-title', tipsyConfig.title

  client.on 'complete', (client, args) ->
    $('#putsreq-url-input').focus().blur()

    $(htmlBridge).prop('title', tipsyConfig.copiedHint).tipsy 'show'
    $(htmlBridge).attr 'original-title', tipsyConfig.title

App.buckets['share'] = App.buckets['show']