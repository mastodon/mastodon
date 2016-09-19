import { createStore, applyMiddleware, compose } from 'redux';
import thunk                                     from 'redux-thunk';
import appReducer                                from '../reducers';
import { loadingBarMiddleware }                  from 'react-redux-loading-bar';

export default function configureStore(initialState) {
  return createStore(appReducer, initialState, compose(applyMiddleware(thunk, loadingBarMiddleware({
    promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'],
  })), window.devToolsExtension ? window.devToolsExtension() : f => f));
};
