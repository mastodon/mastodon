import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appReducer, { createReducer } from '../reducers';
import { hydrateStoreLazy } from '../actions/store';
import { hydrateAction } from '../containers/mastodon';
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
    // Keep track that we injected this reducer
    store.asyncReducers[name] = asyncReducer;

    // Add the current reducer to the store
    store.replaceReducer(createReducer(store.asyncReducers));

    // The state this reducer handles defaults to its initial state (stored inside the reducer)
    // But that state may be out of date because of the server-side hydration, so we replay
    // the hydration action but only for this reducer (all async reducers must listen for this dynamic action)
    store.dispatch(hydrateStoreLazy(name, hydrateAction.state));
  }
}
