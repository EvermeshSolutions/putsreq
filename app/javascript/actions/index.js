import store from '../store'
import fetch from 'cross-fetch'
import { bucketsActions } from '../actionTypes'

const getJSONFromPage = (id) => JSON.parse(document.getElementById(id).innerText)

const fetchFromPage = () => {
  return store.dispatch({
    type: bucketsActions.populate,
    bucket: getJSONFromPage('bucket-json')
  })
}

const favicon = new Favico({ bgColor: '#6C92C8', animation: 'none' })

const updateRequestsCount = (bucket, count) => {
  return (dispatch) => {
    favicon.badge(count)

    if(count == 1) {
      return fetchPage(bucket, count)(dispatch)
    } else {
      return dispatch({ type: bucketsActions.updateRequestCount, requests_count: count })
    }
  }
}

const handlePageChange = (bucket, page) => {
  return (dispatch) => {
    dispatch({ type: bucketsActions.loading })

    fetchPage(bucket, page)(dispatch)
  }
}

const fetchPage = (bucket, page) => {
  return (dispatch) => {
    fetch(`${bucket.path}.json?page=${page}`)
      .then(
        response => response.json(),
        error => console.log('An error occurred.', error)
      )
      .then(json => dispatch({ type: bucketsActions.populate, bucket: json }))
  }
}

export { fetchFromPage, handlePageChange, updateRequestsCount }
