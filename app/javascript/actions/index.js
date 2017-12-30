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

const updateRequestsCount = (count) => {
  return (dispatch, getState) => {
    favicon.badge(count)

    if(count == 1) {
      return fetchPage(1)(dispatch, getState)
    } else {
      return dispatch({ type: bucketsActions.updateRequestCount, requests_count: count })
    }
  }
}

const handlePageChange = (page) => {
  return (dispatch, getState) => {
    dispatch({ type: bucketsActions.loading })

    fetchPage(page)(dispatch, getState)
  }
}

const fetchPage = (page) => {
  return (dispatch, getState) => {
    fetch(`${getState().bucket.path}.json?page=${page}`)
      .then(
        response => response.json(),
        error => console.log('An error occurred.', error)
      )
      .then(json => dispatch({ type: bucketsActions.populate, bucket: json }))
  }
}

export { fetchFromPage, handlePageChange, updateRequestsCount }
