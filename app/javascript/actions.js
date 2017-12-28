import Rx from 'rxjs'
import store from './store'

const getJSONFromPage = (id) => JSON.parse(document.getElementById(id).innerText)

const bucketsActions = {
  fetchBucketRequest: 'FETCH_BUCKET_REQUEST',
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

const fetchBucketRequest = (bucket, page) => {
  return function (dispatch) {
    return fetch(`${bucket.path}.json?page=${page}`)
      .then(
        response => response.json(),
        error => console.log('An error occurred.', error)
      )
      .then(request =>
            store.dispatch({
              type: bucketActions.fetchBucketRequest,
              request
            })
           )
  }
}

export { fetchBucket, handlePageChange, fetchBucketRequest, bucketsActions }
