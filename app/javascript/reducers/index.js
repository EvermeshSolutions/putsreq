import { combineReducers } from 'redux'
import { bucketsActions } from '../actionTypes'

const bucket = (state = {}, action) => {
  switch (action.type) {
  case bucketsActions.populate:
    return { ...action.bucket, loading: false, page: action.page }
  case bucketsActions.loading:
    return { ...state, loading: true, page: action.page }
  case bucketsActions.updateRequestsCount:
    return { ...state, requests_count: action.requests_count, page: action.page }
  default:
    return state
  }
}

const rootReducer = combineReducers({ bucket })

export default rootReducer
