import Rx from 'rxjs'
import store from './store'

const getJSONFromPage = (id) => JSON.parse(document.getElementById(id).innerText)

const bucketsActions = {
  handlePageChange: 'HANDLE_PAGE_CHANGE',
  populate: 'POPULATE'
}

const fetchBucket = () => {
  Rx.Observable.create(obs => {
    obs.next(getJSONFromPage('bucket-json'))
    obs.complete()
  })
    .subscribe((bucket) => {
      store.dispatch({
        type: bucketsActions.populate,
        bucket
      })
    })
}

const handlePageChange = () => {
  return {
    type: bucketsActions.handlePageChange
  }
}

const fetchBucket2 = (bucket, page) => {
  return function (dispatch) {
    return fetch(`${bucket.path}.json?page=${page}`)
      .then(
        response => response.json(),
        error => console.log('An error occurred.', error)
      )
      .then(json =>
            console.log(json)
            // dispatch(receivePosts(subreddit, json))
           )
  }
}

export { fetchBucket, handlePageChange, fetchBucket2, bucketsActions }
