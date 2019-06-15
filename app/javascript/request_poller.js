import { updateRequestsCount } from './actions'

export default function startRequestPoller(store) {
  const bucket = $('#putsreq-url-input').data('bucket-token')

  const url = `/${bucket}/requests_count`
  const poll = (previousRequestsCount = 0) => {
    $.getJSON(url)
    .done((data) => {
      updateRequestsCount(data.requests_count)(store.dispatch, store.getState)
      // use setTimeout instead of setInterval to ensure a new request will be made
      // only when the previous one was completed
      const timeout = previousRequestsCount == data.requests_count ? 5000 : 2500
      setTimeout(() => { poll(data.requests_count) }, timeout)
    })
  }

  poll()
}