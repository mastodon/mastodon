import { combineReducers } from 'redux-immutable';
import timelines from './timelines';
import meta from './meta';
import alerts from './alerts';
import { loadingBarReducer } from 'react-redux-loading-bar';
import modal from './modal';
import user_lists from './user_lists';
import accounts from './accounts';
import accounts_counters from './accounts_counters';
import statuses from './statuses';
import relationships from './relationships';
import settings from './settings';
import status_lists from './status_lists';
import cards from './cards';
import reports from './reports';
import contexts from './contexts';

const reducers = {
  timelines,
  meta,
  alerts,
  loadingBar: loadingBarReducer,
  modal,
  user_lists,
  status_lists,
  accounts,
  accounts_counters,
  statuses,
  relationships,
  settings,
  cards,
  reports,
  contexts,
};

export function createReducer(asyncReducers) {
  return combineReducers({
    ...reducers,
    ...asyncReducers,
  });
}

export default combineReducers(reducers);
