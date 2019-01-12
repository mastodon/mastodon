import api from '../api';
import { importFetchedAccounts } from './importer';

export const SUGGESTIONS_FETCH_REQUEST = 'SUGGESTIONS_FETCH_REQUEST';
export const SUGGESTIONS_FETCH_SUCCESS = 'SUGGESTIONS_FETCH_SUCCESS';
export const SUGGESTIONS_FETCH_FAIL    = 'SUGGESTIONS_FETCH_FAIL';

export const SUGGESTIONS_DISMISS = 'SUGGESTIONS_DISMISS';

export function fetchSuggestions() {
  return (dispatch, getState) => {
    dispatch(fetchSuggestionsRequest());

    api(getState).get('/api/v1/suggestions').then(response => {
      dispatch(importFetchedAccounts(response.data));
      dispatch(fetchSuggestionsSuccess(response.data));
    }).catch(error => dispatch(fetchSuggestionsFail(error)));
  };
};

export function fetchSuggestionsRequest() {
  return {
    type: SUGGESTIONS_FETCH_REQUEST,
    skipLoading: true,
  };
};

export function fetchSuggestionsSuccess(accounts) {
  return {
    type: SUGGESTIONS_FETCH_SUCCESS,
    accounts,
    skipLoading: true,
  };
};

export function fetchSuggestionsFail(error) {
  return {
    type: SUGGESTIONS_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
};

export const dismissSuggestion = accountId => (dispatch, getState) => {
  dispatch({
    type: SUGGESTIONS_DISMISS,
    id: accountId,
  });

  api(getState).delete(`/api/v1/suggestions/${accountId}`);
};
