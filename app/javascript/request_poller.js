import { updateRequestsCount } from './actions'

export default function startRequestPoller(store) {
  const bucket = $('#putsreq-url-input').data('bucket-token')

  const pusher = new Pusher('3466d56fe2ef1fdd2943')
  const channel = pusher.subscribe(`channel_requests_${bucket}`)

  channel.bind('new', (data) => {
    try {
      updateRequestsCount(count)
    } catch(error) {}
  })
}
