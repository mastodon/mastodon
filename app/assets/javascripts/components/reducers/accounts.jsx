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
import { COMPOSE_SUGGESTIONS_READY } from '../actions/compose';
import {
  REBLOG_SUCCESS,
  UNREBLOG_SUCCESS,
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS,
  REBLOGS_FETCH_SUCCESS,
  FAVOURITES_FETCH_SUCCESS
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
import { SEARCH_SUGGESTIONS_READY } from '../actions/search';
import Immutable from 'immutable';

const normalizeAccount = (state, account) => state.set(account.id, Immutable.fromJS(account));

const normalizeAccounts = (state, accounts) => {
  accounts.forEach(account => {
    state = normalizeAccount(state, account);
  });

  return state;
};

const normalizeAccountFromStatus = (state, status) => {
  state = normalizeAccount(state, status.account);

  if (status.reblog && status.reblog.account) {
    state = normalizeAccount(state, status.reblog.account);
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
      return normalizeAccount(state, action.account);
    case SUGGESTIONS_FETCH_SUCCESS:
    case FOLLOWERS_FETCH_SUCCESS:
    case FOLLOWING_FETCH_SUCCESS:
    case REBLOGS_FETCH_SUCCESS:
    case FAVOURITES_FETCH_SUCCESS:
    case COMPOSE_SUGGESTIONS_READY:
    case SEARCH_SUGGESTIONS_READY:
      return normalizeAccounts(state, action.accounts);
    case TIMELINE_REFRESH_SUCCESS:
    case TIMELINE_EXPAND_SUCCESS:
    case ACCOUNT_TIMELINE_FETCH_SUCCESS:
    case ACCOUNT_TIMELINE_EXPAND_SUCCESS:
    case CONTEXT_FETCH_SUCCESS:
      return normalizeAccountsFromStatuses(state, action.statuses);
    case REBLOG_SUCCESS:
    case FAVOURITE_SUCCESS:
    case UNREBLOG_SUCCESS:
    case UNFAVOURITE_SUCCESS:
      return normalizeAccountFromStatus(state, action.response);
    case TIMELINE_UPDATE:
    case STATUS_FETCH_SUCCESS:
      return normalizeAccountFromStatus(state, action.status);
    default:
      return state;
  }
};
