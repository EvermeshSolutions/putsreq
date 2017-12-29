import { combineReducers } from 'redux'
import { bucketsActions } from '../actionTypes'

const bucket = (state = {}, action) => {
  switch (action.type) {
  case bucketsActions.populate:
    return action.bucket
  default:
    return state
  }
}

const rootReducer = combineReducers({ bucket })

export default rootReducer
