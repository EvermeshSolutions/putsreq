import fetch from 'cross-fetch'
import { bucketsActions } from '../actionTypes'

const getJSONFromPage = (id) => JSON.parse(document.getElementById(id).innerText)

const fetchFromPage = () => {
  const bucket = getJSONFromPage('bucket-json')
  favicon.badge(bucket.requests_count)

  return {
    type: bucketsActions.populate,
    bucket,
    page: 1
  }
}

const favicon = new Favico({ bgColor: '#6C92C8', animation: 'none' })

const updateRequestsCount = (count) => {
  return (dispatch, getState) => {
    favicon.badge(count)

    dispatch({ type: bucketsActions.updateRequestsCount, requests_count: count, page: null })

    if(count == 1) {
      return fetchPage(1)(dispatch, getState)
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
      .then(bucket => dispatch({ type: bucketsActions.populate, bucket, page }))
  }
}

export { fetchFromPage, handlePageChange, updateRequestsCount }
