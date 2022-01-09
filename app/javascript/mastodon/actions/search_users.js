import api from '../api';
import { fetchRelationships } from './accounts';
import { importFetchedAccounts } from './importer';

export const SEARCH_USERS_CHANGE = 'SEARCH_USERS_CHANGE';
export const SEARCH_USERS_CLEAR = 'SEARCH_USERS_CLEAR';
export const SEARCH_USERS_SHOW = 'SEARCH_USERS_SHOW';

export const SEARCH_USERS_FETCH_REQUEST = 'SEARCH_USERS_FETCH_REQUEST';
export const SEARCH_USERS_FETCH_SUCCESS = 'SEARCH_USERS_FETCH_SUCCESS';
export const SEARCH_USERS_FETCH_FAIL = 'SEARCH_USERS_FETCH_FAIL';

export const SEARCH_USERS_EXPAND_REQUEST = 'SEARCH_USERS_EXPAND_REQUEST';
export const SEARCH_USERS_EXPAND_SUCCESS = 'SEARCH_USERS_EXPAND_SUCCESS';
export const SEARCH_USERS_EXPAND_FAIL = 'SEARCH_USERS_EXPAND_FAIL';

export function changeSearch(value) {
  return {
    type: SEARCH_USERS_CHANGE,
    value,
  };
}

export function clearSearch() {
  return {
    type: SEARCH_USERS_CLEAR,
  };
}

export function submitSearch() {
  return (dispatch, getState) => {
    const value = getState().getIn(['searchUsers', 'value']);

    if (value.length === 0) {
      dispatch(fetchSearchSuccess({ accounts: [] }, ''));
      return;
    }

    dispatch(fetchSearchRequest());

    api(getState)
      .get('/api/v2/search', {
        params: {
          q: value,
          resolve: true,
          limit: 3,
        },
      })
      .then((response) => {
        if (response.data.accounts) {
          dispatch(importFetchedAccounts(response.data.accounts));
        }

        dispatch(fetchSearchSuccess(response.data, value));
        dispatch(
          fetchRelationships(response.data.accounts.map((item) => item.id))
        );
      })
      .catch((error) => {
        dispatch(fetchSearchFail(error));
      });
  };
}

export function fetchSearchRequest() {
  return {
    type: SEARCH_USERS_FETCH_REQUEST,
  };
}

export function fetchSearchSuccess(results, searchTerm) {
  return {
    type: SEARCH_USERS_FETCH_SUCCESS,
    results,
    searchTerm,
  };
}

export function fetchSearchFail(error) {
  return {
    type: SEARCH_USERS_FETCH_FAIL,
    error,
  };
}

export const expandSearch = (type) => (dispatch, getState) => {
  const value = getState().getIn(['searchUsers', 'value']);
  const offset = getState().getIn(['searchUsers', 'results', type]).size;

  dispatch(expandSearchRequest());

  api(getState)
    .get('/api/v2/search', {
      params: {
        q: value,
        type,
        offset,
      },
    })
    .then(({ data }) => {
      if (data.accounts) {
        dispatch(importFetchedAccounts(data.accounts));
      }

      dispatch(expandSearchSuccess(data, value, type));
      dispatch(fetchRelationships(data.accounts.map((item) => item.id)));
    })
    .catch((error) => {
      dispatch(expandSearchFail(error));
    });
};

export const expandSearchRequest = () => ({
  type: SEARCH_USERS_EXPAND_REQUEST,
});

export const expandSearchSuccess = (results, searchTerm, searchType) => ({
  type: SEARCH_USERS_EXPAND_SUCCESS,
  results,
  searchTerm,
  searchType,
});

export const expandSearchFail = (error) => ({
  type: SEARCH_USERS_EXPAND_FAIL,
  error,
});

export const showSearch = () => ({
  type: SEARCH_USERS_SHOW,
});
