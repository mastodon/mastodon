import { fromJS } from 'immutable';

import { searchHistory } from 'flavours/glitch/settings';

import api from '../api';

import { fetchRelationships } from './accounts';
import { importFetchedAccounts, importFetchedStatuses } from './importer';

export const SEARCH_CHANGE = 'SEARCH_CHANGE';
export const SEARCH_CLEAR  = 'SEARCH_CLEAR';
export const SEARCH_SHOW   = 'SEARCH_SHOW';

export const SEARCH_FETCH_REQUEST = 'SEARCH_FETCH_REQUEST';
export const SEARCH_FETCH_SUCCESS = 'SEARCH_FETCH_SUCCESS';
export const SEARCH_FETCH_FAIL    = 'SEARCH_FETCH_FAIL';

export const SEARCH_EXPAND_REQUEST = 'SEARCH_EXPAND_REQUEST';
export const SEARCH_EXPAND_SUCCESS = 'SEARCH_EXPAND_SUCCESS';
export const SEARCH_EXPAND_FAIL    = 'SEARCH_EXPAND_FAIL';

export const SEARCH_HISTORY_UPDATE  = 'SEARCH_HISTORY_UPDATE';

export function changeSearch(value) {
  return {
    type: SEARCH_CHANGE,
    value,
  };
}

export function clearSearch() {
  return {
    type: SEARCH_CLEAR,
  };
}

export function submitSearch(type) {
  return (dispatch, getState) => {
    const value    = getState().getIn(['search', 'value']);
    const signedIn = !!getState().getIn(['meta', 'me']);

    if (value.length === 0) {
      dispatch(fetchSearchSuccess({ accounts: [], statuses: [], hashtags: [] }, '', type));
      return;
    }

    dispatch(fetchSearchRequest(type));

    api().get('/api/v2/search', {
      params: {
        q: value,
        resolve: signedIn,
        limit: 11,
        type,
      },
    }).then(response => {
      if (response.data.accounts) {
        dispatch(importFetchedAccounts(response.data.accounts));
      }

      if (response.data.statuses) {
        dispatch(importFetchedStatuses(response.data.statuses));
      }

      dispatch(fetchSearchSuccess(response.data, value, type));
      dispatch(fetchRelationships(response.data.accounts.map(item => item.id)));
    }).catch(error => {
      dispatch(fetchSearchFail(error));
    });
  };
}

export function fetchSearchRequest(searchType) {
  return {
    type: SEARCH_FETCH_REQUEST,
    searchType,
  };
}

export function fetchSearchSuccess(results, searchTerm, searchType) {
  return {
    type: SEARCH_FETCH_SUCCESS,
    results,
    searchType,
    searchTerm,
  };
}

export function fetchSearchFail(error) {
  return {
    type: SEARCH_FETCH_FAIL,
    error,
  };
}

export const expandSearch = type => (dispatch, getState) => {
  const value  = getState().getIn(['search', 'value']);
  const offset = getState().getIn(['search', 'results', type]).size - 1;

  dispatch(expandSearchRequest(type));

  api().get('/api/v2/search', {
    params: {
      q: value,
      type,
      offset,
      limit: 11,
    },
  }).then(({ data }) => {
    if (data.accounts) {
      dispatch(importFetchedAccounts(data.accounts));
    }

    if (data.statuses) {
      dispatch(importFetchedStatuses(data.statuses));
    }

    dispatch(expandSearchSuccess(data, value, type));
    dispatch(fetchRelationships(data.accounts.map(item => item.id)));
  }).catch(error => {
    dispatch(expandSearchFail(error));
  });
};

export const expandSearchRequest = (searchType) => ({
  type: SEARCH_EXPAND_REQUEST,
  searchType,
});

export const expandSearchSuccess = (results, searchTerm, searchType) => ({
  type: SEARCH_EXPAND_SUCCESS,
  results,
  searchTerm,
  searchType,
});

export const expandSearchFail = error => ({
  type: SEARCH_EXPAND_FAIL,
  error,
});

export const showSearch = () => ({
  type: SEARCH_SHOW,
});

export const openURL = (value, history, onFailure) => (dispatch, getState) => {
  const signedIn = !!getState().getIn(['meta', 'me']);

  if (!signedIn) {
    if (onFailure) {
      onFailure();
    }

    return;
  }

  dispatch(fetchSearchRequest());

  api().get('/api/v2/search', { params: { q: value, resolve: true } }).then(response => {
    if (response.data.accounts?.length > 0) {
      dispatch(importFetchedAccounts(response.data.accounts));
      history.push(`/@${response.data.accounts[0].acct}`);
    } else if (response.data.statuses?.length > 0) {
      dispatch(importFetchedStatuses(response.data.statuses));
      history.push(`/@${response.data.statuses[0].account.acct}/${response.data.statuses[0].id}`);
    } else if (onFailure) {
      onFailure();
    }

    dispatch(fetchSearchSuccess(response.data, value));
  }).catch(err => {
    dispatch(fetchSearchFail(err));

    if (onFailure) {
      onFailure();
    }
  });
};

export const clickSearchResult = (q, type) => (dispatch, getState) => {
  const previous = getState().getIn(['search', 'recent']);

  if (previous.some(x => x.get('q') === q && x.get('type') === type)) {
    return;
  }

  const me = getState().getIn(['meta', 'me']);
  const current = previous.add(fromJS({ type, q })).takeLast(4);

  searchHistory.set(me, current.toJS());
  dispatch(updateSearchHistory(current));
};

export const forgetSearchResult = q => (dispatch, getState) => {
  const previous = getState().getIn(['search', 'recent']);
  const me = getState().getIn(['meta', 'me']);
  const current = previous.filterNot(result => result.get('q') === q);

  searchHistory.set(me, current.toJS());
  dispatch(updateSearchHistory(current));
};

export const updateSearchHistory = recent => ({
  type: SEARCH_HISTORY_UPDATE,
  recent,
});

export const hydrateSearch = () => (dispatch, getState) => {
  const me = getState().getIn(['meta', 'me']);
  const history = searchHistory.get(me);

  if (history !== null) {
    dispatch(updateSearchHistory(history));
  }
};
