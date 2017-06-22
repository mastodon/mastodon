import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appReducer, { createReducer } from '../reducers';
import { hydrateStoreLazy } from '../actions/store';
import { initialState } from '../containers/mastodon';
import loadingBarMiddleware from '../middleware/loading_bar';
import errorsMiddleware from '../middleware/errors';
import soundsMiddleware from '../middleware/sounds';

export default function configureStore() {
  const store = createStore(appReducer, compose(applyMiddleware(
    thunk,
    loadingBarMiddleware({ promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'] }),
    errorsMiddleware(),
    soundsMiddleware()
  ), window.devToolsExtension ? window.devToolsExtension() : f => f));

  store.asyncReducers = { };

  return store;
};

export function injectAsyncReducer(store, name, asyncReducer) {
  if (!store.asyncReducers[name]) {
    store.asyncReducers[name] = asyncReducer;
    store.replaceReducer(createReducer(store.asyncReducers));
    store.dispatch(hydrateStoreLazy(name, initialState));
  }
}
