import { fromJS } from 'immutable';
import { createStore, applyMiddleware, compose } from 'redux';
import { createTransform, persistReducer } from 'redux-persist';
import storage from 'redux-persist/lib/storage';
import thunk from 'redux-thunk';
import initialState from '../initial_state';
import appReducer from '../reducers';
import loadingBarMiddleware from '../middleware/loading_bar';
import errorsMiddleware from '../middleware/errors';
import soundsMiddleware from '../middleware/sounds';

function immutableTransform(config) {
  return createTransform(
    object => object.toJSON ? object.toJSON() : JSON.stringify(object),
    string => fromJS(JSON.parse(string)),
    config
  );
}

const persistConfig = {
  key: 'mastodon:' + initialState.meta.me,
  storage,
  transforms: [immutableTransform()],
  whitelist: [
    'accounts', 'accounts_counters', 'cards', 'contexts',
    'lists', 'media_attachments', 'mutes', 'notifications',
    'relationships', 'settings', 'status_lists', 'statuses',
    'timelines', 'user_lists',
  ],
};

export default function configureStore() {
  return createStore(persistReducer(persistConfig, appReducer), compose(applyMiddleware(
    thunk,
    loadingBarMiddleware({ promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'] }),
    errorsMiddleware(),
    soundsMiddleware()
  ), window.devToolsExtension ? window.devToolsExtension() : f => f));
};
