import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers';

export default function configureStore(initialState) {
  return createStore(appReducer, initialState, compose(applyMiddleware(thunk), window.devToolsExtension ? window.devToolsExtension() : f => f));
}
