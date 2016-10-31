import {
  ACCOUNT_SET_SELF,
  ACCOUNT_FETCH_SUCCESS,
  FOLLOWERS_FETCH_SUCCESS,
  FOLLOWING_FETCH_SUCCESS,
  ACCOUNT_TIMELINE_FETCH_SUCCESS,
  ACCOUNT_TIMELINE_EXPAND_SUCCESS
} from '../actions/accounts';
import { FOLLOW_SUBMIT_SUCCESS } from '../actions/follow';
import { SUGGESTIONS_FETCH_SUCCESS } from '../actions/suggestions';
import {
  REBLOG_SUCCESS,
  UNREBLOG_SUCCESS,
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS
} from '../actions/interactions';
import {
  TIMELINE_REFRESH_SUCCESS,
  TIMELINE_UPDATE,
  TIMELINE_EXPAND_SUCCESS
} from '../actions/timelines';
import {
  STATUS_FETCH_SUCCESS,
  CONTEXT_FETCH_SUCCESS
} from '../actions/statuses';
import Immutable from 'immutable';

const normalizeAccount = (state, account) => state.set(account.get('id'), account);

const normalizeAccounts = (state, accounts) => {
  accounts.forEach(account => {
    state = normalizeAccount(state, account);
  });

  return state;
};

const normalizeAccountFromStatus = (state, status) => {
  state = normalizeAccount(state, status.get('account'));

  if (status.getIn(['reblog', 'account'])) {
    state = normalizeAccount(state, status.getIn(['reblog', 'account']));
  }

  return state;
};

const normalizeAccountsFromStatuses = (state, statuses) => {
  statuses.forEach(status => {
    state = normalizeAccountFromStatus(state, status);
  });

  return state;
};

const initialState = Immutable.Map();

export default function accounts(state = initialState, action) {
  switch(action.type) {
    case ACCOUNT_SET_SELF:
    case ACCOUNT_FETCH_SUCCESS:
    case FOLLOW_SUBMIT_SUCCESS:
      return normalizeAccount(state, Immutable.fromJS(action.account));
    case SUGGESTIONS_FETCH_SUCCESS:
    case FOLLOWERS_FETCH_SUCCESS:
    case FOLLOWING_FETCH_SUCCESS:
      return normalizeAccounts(state, Immutable.fromJS(action.accounts));
    case TIMELINE_REFRESH_SUCCESS:
    case TIMELINE_EXPAND_SUCCESS:
    case ACCOUNT_TIMELINE_FETCH_SUCCESS:
    case ACCOUNT_TIMELINE_EXPAND_SUCCESS:
    case CONTEXT_FETCH_SUCCESS:
      return normalizeAccountsFromStatuses(state, Immutable.fromJS(action.statuses));
    case TIMELINE_UPDATE:
    case REBLOG_SUCCESS:
    case FAVOURITE_SUCCESS:
    case UNREBLOG_SUCCESS:
    case UNFAVOURITE_SUCCESS:
    case STATUS_FETCH_SUCCESS:
      return normalizeAccountFromStatus(state, Immutable.fromJS(action.status));
    default:
      return state;
  }
};
