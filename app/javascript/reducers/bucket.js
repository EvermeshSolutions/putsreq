import { bucketsActions } from '../constants/actionTypes'

export default (state = {}, action) => {
  switch (action.type) {
  case bucketsActions.populate:
    return action.bucket
  default:
    return state
  }
}
