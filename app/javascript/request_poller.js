import { updateRequestsCount } from './actions'

export default function startRequestPoller(store) {
  const bucket = $('#putsreq-url-input').data('bucket-token')

  const pusher = new Pusher($('body').data('pusher-key'), { cluster: $('body').data('pusher-cluster'), encrypted: true })

  const channel = pusher.subscribe(`channel_requests_${bucket}`)

  channel.bind('new', (data) => {
    updateRequestsCount(data.count)(store.dispatch, store.getState)
  })
}
