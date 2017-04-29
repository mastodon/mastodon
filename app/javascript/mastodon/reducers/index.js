import { combineReducers } from 'redux-immutable';
import timelines from './timelines';
import meta from './meta';
import compose from './compose';
import alerts from './alerts';
import { loadingBarReducer } from 'react-redux-loading-bar';
import modal from './modal';
import user_lists from './user_lists';
import accounts from './accounts';
import statuses from './statuses';
import relationships from './relationships';
import search from './search';
import notifications from './notifications';
import settings from './settings';
import status_lists from './status_lists';
import cards from './cards';
import reports from './reports';

export default combineReducers({
  timelines,
  meta,
  compose,
  alerts,
  loadingBar: loadingBarReducer,
  modal,
  user_lists,
  status_lists,
  accounts,
  statuses,
  relationships,
  search,
  notifications,
  settings,
  cards,
  reports
});
