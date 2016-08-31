import { combineReducers } from 'redux-immutable';
import timelines           from './timelines';
import meta                from './meta';
import compose             from './compose';

export default combineReducers({
  timelines,
  meta,
  compose
});
