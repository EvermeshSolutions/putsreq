$(function(){
  var editor = ace.edit('editor');
  editor.setTheme('ace/theme/monokai');
  editor.getSession().setMode('ace/mode/javascript');
  editor.getSession().on('change', function(){
    $('#response_builder').val(editor.getSession().getValue());
  });

  editor.setValue($('#response-builder-container').text());
  editor.clearSelection();

  var _defaults = {
    title: 'Copy to Clipboard',
    copied_hint: 'Copied!',
    gravity: $.fn.tipsy.autoNS
  };

  var client = new ZeroClipboard($('#copy-button'), {
    moviePath: '/flash/ZeroClipboard.swf',
    title: "teste"
  });

  var htmlBridge = "#global-zeroclipboard-html-bridge";

  client.on( "ready", function( readyEvent ) {
    $(htmlBridge).tipsy({ gravity: _defaults.gravity });
    $(htmlBridge).attr('title', _defaults.title);
    client.on( "aftercopy", function( event ) {
      // alert("Copied text to clipboard: " + event.data["text/plain"] );
      var copied_hint = $(this).data('copied-hint');
      if (!copied_hint) {
        copied_hint = _defaults.copied_hint;
      }
      $(htmlBridge)
        .prop('title', copied_hint)
        .tipsy('show');
    });

  });

});
