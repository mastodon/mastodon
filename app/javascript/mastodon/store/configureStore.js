import { createStore, applyMiddleware, compose } from 'redux';
import thunkMiddleWare from 'redux-thunk';
import appReducer from '../reducers';
import loadingBarMiddleware from '../middleware/loading_bar';
import errorsMiddleware from '../middleware/errors';
import soundsMiddleware from '../middleware/sounds';
import {
  email,
  tankerIdentity,
  tankerAppId,
} from '../initial_state';
import TankerService from '../tanker';

const tankerService = new TankerService({ email, tankerIdentity, tankerAppId });
const thunk = thunkMiddleWare.withExtraArgument({ tankerService });

export default function configureStore() {
  return createStore(appReducer, compose(applyMiddleware(
    thunk,
    loadingBarMiddleware({ promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'] }),
    errorsMiddleware(),
    soundsMiddleware()
  ), window.__REDUX_DEVTOOLS_EXTENSION__ ? window.__REDUX_DEVTOOLS_EXTENSION__() : f => f));
};
