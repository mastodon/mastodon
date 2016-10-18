import { createStore, applyMiddleware, compose } from 'redux';
import thunk                                     from 'redux-thunk';
import appReducer                                from '../reducers';
import { loadingBarMiddleware }                  from 'react-redux-loading-bar';
import errorsMiddleware                          from '../middleware/errors';

export default function configureStore(initialState) {
  return createStore(appReducer, initialState, compose(applyMiddleware(thunk, loadingBarMiddleware({
    promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'],
  }), errorsMiddleware()), window.devToolsExtension ? window.devToolsExtension() : f => f));
};
