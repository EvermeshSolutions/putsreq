import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import store from '../store'
import Bucket from '../components/Bucket'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
      <Provider store={store}>
        <Bucket />
      </Provider>,
    document.getElementById('react-root')
  )
})
