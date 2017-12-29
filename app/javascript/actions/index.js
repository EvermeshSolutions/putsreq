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

const handlePageChange = (bucket, page) => {
  return (dispatch) => {
    dispatch({ type: bucketsActions.loading })

    return fetch(`${bucket.path}.json?page=${page}`)
      .then(
        response => response.json(),
        error => console.log('An error occurred.', error)
      )
      .then(json =>
            dispatch({ type: bucketsActions.populate, bucket: getJSONFromPage('bucket-json') })
           )
  }
}

export { fetchFromPage, handlePageChange }
