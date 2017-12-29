import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import store from '../store'
import Bucket from '../components/Bucket'
import RequestCount from '../components/RequestCount'
import startRequestPoller from '../request_poller'
import { updateRequestsCount } from '../actions'


document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
      <Provider store={store}>
        <Bucket />
      </Provider>,
    document.getElementById('react-root')
  )

  ReactDOM.render(
      <Provider store={store}>
        <RequestCount />
      </Provider>,
    document.getElementById('request-count-react-root')
  )
})

$(() => startRequestPoller(store))

window.xpto = (c) => {
  updateRequestsCount(c)
}
