import store from '../store'
import { bucketsActions } from '../actionTypes'

const getJSONFromPage = (id) => JSON.parse(document.getElementById(id).innerText)

const fetchFromPage = () => {
  return store.dispatch({
    type: bucketsActions.populate,
    bucket: getJSONFromPage('bucket-json')
  })
}

const handlePageChange = (bucket, page) => {
  return fetchFromPage()
}

export { fetchFromPage, handlePageChange }
