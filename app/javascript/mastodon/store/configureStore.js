import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers';
import loadingBarMiddleware from '../middleware/loading_bar';
import errorsMiddleware from '../middleware/errors';
import soundsMiddleware from '../middleware/sounds';
import { LocalForage, ReduxPersistImmutable } from '../features/ui/util/async-components';

export default function configureStore() {
  const store = createStore(appReducer, compose(applyMiddleware(
    thunk,
    loadingBarMiddleware({ promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'] }),
    errorsMiddleware(),
    soundsMiddleware()
  ), window.devToolsExtension ? window.devToolsExtension() : f => f));

  if ('serviceWorker' in navigator) {
    requestIdleCallback(() => {
      const fetchPackages = Promise.all([LocalForage(), ReduxPersistImmutable()]);

      fetchPackages.then(([localForage, { persistStore }]) => {
        requestIdleCallback(() => {
          persistStore(store, {
            storage: localForage,
            whitelist: [
              'accounts',
              'statuses',
              'timelines',
              'notifications',
            ],
            debounce: 30,
          });
        });
      });
    });
  }

  return store;
};
