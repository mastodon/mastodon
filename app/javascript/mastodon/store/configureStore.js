import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers';
import loadingBarMiddleware from '../middleware/loading_bar';
import errorsMiddleware from '../middleware/errors';
import soundsMiddleware from '../middleware/sounds';
import modalMiddleware from '../middleware/modal';
import { closeModal } from '../actions/modal';
import Immutable from 'immutable';

export default function configureStore({ history }) {
  const store = createStore(appReducer, compose(applyMiddleware(
    thunk,
    loadingBarMiddleware({ promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'] }),
    errorsMiddleware(),
    soundsMiddleware(),
    modalMiddleware(history),
  ), window.devToolsExtension ? window.devToolsExtension() : f => f));

  // If the user navigates back and the modal is open, close it
  history.listen((location) => {
    if (location.action === 'POP' && typeof store.getState().getIn(['modal']).modalType === 'string') {
      store.dispatch(closeModal({ skipGoingBack: true }));
    }
  });

  return store;
};
