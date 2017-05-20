import { combineReducers } from 'redux-immutable';
import timelines from './timelines';
import meta from './meta';
import compose from './compose';
import alerts from './alerts';
import { loadingBarReducer } from 'react-redux-loading-bar';
import modal from './modal';
import user_lists from './user_lists';
import accounts from './accounts';
import accounts_counters from './accounts_counters';
import statuses from './statuses';
import media_attachments from './media_attachments';
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
  accounts_counters,
  media_attachments,
  statuses,
  relationships,
  search,
  notifications,
  settings,
  cards,
  reports,
});
