import Rx from 'rxjs'
import store from '../../store'

const getJSONFromPage = (id) => JSON.parse(document.getElementById(id).innerText)

const fetchBucket = () => {
  Rx.Observable.create(obs => {
    obs.next(getJSONFromPage('bucket-json'))
    obs.complete()
  })
    .subscribe((bucket) => {
      store.dispatch({
        type: 'BUCKET_POPULATE',
        bucket
      })
    })
}
export { fetchBucket }
