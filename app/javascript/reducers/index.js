import { combineReducers } from 'redux'
import { bucketsActions } from '../actionTypes'

const bucket = (state = {}, action) => {
  switch (action.type) {
  case bucketsActions.populate:
    return { ...action.bucket, loading: false, page: action.page || 0 }
  case bucketsActions.loading:
    return { ...state, loading: true }
  case bucketsActions.updateRequestsCount:
    return { ...state, requests_count: action.requests_count, previous_requests_count: state.requests_count }
  default:
    return state
  }
}

const rootReducer = combineReducers({ bucket })

export default rootReducer
