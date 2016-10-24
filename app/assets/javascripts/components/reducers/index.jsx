import { combineReducers }   from 'redux-immutable';
import timelines             from './timelines';
import meta                  from './meta';
import compose               from './compose';
import follow                from './follow';
import notifications         from './notifications';
import { loadingBarReducer } from 'react-redux-loading-bar';
import modal                 from './modal';

export default combineReducers({
  timelines,
  meta,
  compose,
  follow,
  notifications,
  loadingBar: loadingBarReducer,
  modal,
});
