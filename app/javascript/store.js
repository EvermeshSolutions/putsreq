import { createStore, applyMiddleware } from 'redux'
import thunk from 'redux-thunk'
import { composeWithDevTools } from 'redux-devtools-extension'
import rootReducers from './reducers'

export default createStore(
  rootReducers,
  composeWithDevTools(applyMiddleware(thunk))
)
