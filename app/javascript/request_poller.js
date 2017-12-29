import { updateRequestsCount } from './actions'

export default function startRequestPoller(store) {
  const bucket = $('#putsreq-url-input').data('bucket-token')

  const pusher = new Pusher('1ea9571bd3195cac6d9c', { cluster: 'us2', encrypted: true })
  const channel = pusher.subscribe(`channel_requests_${bucket}`)

  channel.bind('new', (data) => {
    try {
      updateRequestsCount(store.getState().bucket, data.count)(store.dispatch)
    } catch(error) {}
  })
}
