import { bucketsActions } from './actionTypes.js'

export default function startRequestPoller(store) {
  const favicon = new Favico({ bgColor: '#6C92C8', animation: 'none' })

  const bucket = $('#putsreq-url-input').data('bucket-token')

  const pusher = new Pusher('3466d56fe2ef1fdd2943')
  const channel = pusher.subscribe(`channel_requests_${bucket}`)

  channel.bind('new', (data) => {
    try {
      favicon.badge(data.count)

      store.dispatch({ type: bucketsActions.updateRequestCount, requests_count: data.count })
    } catch(error) {}
  })
}
