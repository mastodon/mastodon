import { combineReducers }   from 'redux-immutable';
import timelines             from './timelines';
import meta                  from './meta';
import compose               from './compose';
import follow                from './follow';
import notifications         from './notifications';
import { loadingBarReducer } from 'react-redux-loading-bar';
import modal                 from './modal';
import user_lists            from './user_lists';
import accounts              from './accounts';
import statuses              from './statuses';
import relationships         from './relationships';
import search                from './search';

export default combineReducers({
  timelines,
  meta,
  compose,
  follow,
  notifications,
  loadingBar: loadingBarReducer,
  modal,
  user_lists,
  accounts,
  statuses,
  relationships,
  search
});
