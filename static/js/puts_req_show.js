$(function(){
  var editor = ace.edit('editor');
  editor.setTheme('ace/theme/monokai');
  editor.getSession().setMode('ace/mode/javascript');
  editor.getSession().on('change', function(){
    $('#response_builder').val(editor.getSession().getValue());
  });

  editor.setValue($('#response-builder-container').text());
  editor.clearSelection();

  var clip = new ZeroClipboard($('#copy-puts_req-url'), {
    moviePath: '/js/vendor/ZeroClipboard.swf'
  });

  clip.on('load', function(client) {
    $('#copy-puts_req-url').prop('title', 'copy to clipboard').
    tooltip('destroy').
    tooltip({ 'delay': { show: 500, hide: 100 } })
  });

  clip.on('complete', function(client, args) {
    $('#copy-puts_req-url').
    tooltip('destroy').
    prop('title', 'copied!').
    tooltip({ 'delay': { show: 500, hide: 100 } })
    tooltip('show');
  });

  clip.on('noflash wrongflash', function(client) {
    $('#copy-puts_req-url').hide();
  });
});
