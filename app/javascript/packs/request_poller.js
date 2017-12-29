export default function startRequestPoller() {
  const favicon = new Favico({ bgColor: '#6C92C8', animation: 'none' })
  favicon.badge($('#bucket-request-count').text())

  const bucket = $('#putsreq-url-input').data('bucket-token')

  const pusher = new Pusher('3466d56fe2ef1fdd2943')
  const channel = pusher.subscribe(`channel_requests_${bucket}`)

  channel.bind('new', (data) => {
    try {
      $('#bucket-request-count').text(data.count)

      favicon.badge(data.count)
    } catch(error) {}

    $('#new-requests-info').hide().
      html('<em><a id="new-requests-received" href="javascript:window.location.reload();">New requests found. Load newer requests?</a></em>').fadeIn('slow')
  })
}
