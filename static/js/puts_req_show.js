$(function(){
  var editor = ace.edit('editor');
  editor.setTheme('ace/theme/monokai');
  editor.getSession().setMode('ace/mode/javascript');
  editor.getSession().on('change', function(){
    $('#response_builder').val(editor.getSession().getValue());
  });

  editor.setValue($('#response-builder-container').text());
  editor.clearSelection();

  var tipsyConfig = {
    title:       'Copy to Clipboard',
    copiedHint:  'Copied!',
    gravity:     $.fn.tipsy.autoNS
  };

  ZeroClipboard.config({ swfPath: '/flash/ZeroClipboard.swf' });

  var client = new ZeroClipboard($('#copy-button'));
  var htmlBridge = '#global-zeroclipboard-html-bridge';

  client.on('ready', function(readyEvent){
    $(htmlBridge).tipsy({ gravity: tipsyConfig.gravity });
    $(htmlBridge).attr('title', tipsyConfig.title);

    client.on('aftercopy', function(event){
      var copiedHint = tipsyConfig.copiedHint;
      $('#putsreq-url-input').focus().blur();
      $(htmlBridge)
      .prop('title', tipsyConfig.copiedHint)
      .tipsy('show');

      $(htmlBridge)
      .attr('original-title', tipsyConfig.title);
    });
  });
});
