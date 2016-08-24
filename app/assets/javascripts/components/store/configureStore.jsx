import { createStore } from 'redux';
import appReducer from '../reducers';

export default function configureStore(initialState) {
  return createStore(appReducer, initialState);
}
