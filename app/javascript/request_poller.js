import { updateRequestsCount } from './actions'

export default function startRequestPoller(store) {
  const bucket = $('#putsreq-url-input').data('bucket-token')

  // const source = new EventSource(`/${bucket}/requests_count`)
  // source.addEventListener('requests_count', event => {
  //   const data = JSON.parse(event.data)
  //   updateRequestsCount(data.requests_count)(store.dispatch, store.getState)
  // })
}
