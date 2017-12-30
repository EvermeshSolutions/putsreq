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
    if(count === getState().bucket.requests_count) { return }

    favicon.badge(count)

    let page = getState().bucket.page || 1

    if(count > getState().bucket.request_count) {
      page = (count - getState().bucket.requests_count) + page
    }

    dispatch({ type: bucketsActions.updateRequestsCount, requests_count: count, page: page })

    if(count === 1) { return fetchPage(1)(dispatch, getState) }
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
    fetch(`${getState().bucket.path}.json?page=${1000}`)
      .then(
        response => response.json(),
        error => console.log('An error occurred.', error)
      )
      .then(bucket => dispatch({ type: bucketsActions.populate, bucket, page }))
  }
}

export { fetchFromPage, handlePageChange, updateRequestsCount }
