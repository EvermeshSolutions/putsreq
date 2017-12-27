import Rx from 'rxjs'
import store from '../../store'
import { bucketsActions } from '../../constants/actionTypes'

const getJSONFromPage = (id) => JSON.parse(document.getElementById(id).innerText)

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
export { fetchBucket }
