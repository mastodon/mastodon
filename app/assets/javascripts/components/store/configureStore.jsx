import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers';
import loadingBarMiddleware from '../middleware/loading_bar';
import errorsMiddleware from '../middleware/errors';
import soundsMiddleware from 'redux-sounds';
import Howler from 'howler';
import Immutable from 'immutable';

Howler.mobileAutoEnable = false;

const soundsData = {
  boop: '/sounds/boop.mp3'
};

export default function configureStore() {
  return createStore(appReducer, compose(applyMiddleware(
    thunk,
    loadingBarMiddleware({ promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'] }),
    errorsMiddleware(),
    soundsMiddleware(soundsData)
  ), window.devToolsExtension ? window.devToolsExtension() : f => f));
};
