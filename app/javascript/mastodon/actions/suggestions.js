import api from '../api';

import { fetchRelationships } from './accounts';
import { importFetchedAccounts } from './importer';

export const SUGGESTIONS_FETCH_REQUEST = 'SUGGESTIONS_FETCH_REQUEST';
export const SUGGESTIONS_FETCH_SUCCESS = 'SUGGESTIONS_FETCH_SUCCESS';
export const SUGGESTIONS_FETCH_FAIL    = 'SUGGESTIONS_FETCH_FAIL';

export const SUGGESTIONS_DISMISS = 'SUGGESTIONS_DISMISS';

export function fetchSuggestions(withRelationships = false) {
  return (dispatch) => {
    dispatch(fetchSuggestionsRequest());

    api().get('/api/v2/suggestions', { params: { limit: 20 } }).then(response => {
      dispatch(importFetchedAccounts(response.data.map(x => x.account)));
      dispatch(fetchSuggestionsSuccess(response.data));

      if (withRelationships) {
        dispatch(fetchRelationships(response.data.map(item => item.account.id)));
      }
    }).catch(error => dispatch(fetchSuggestionsFail(error)));
  };
}

export function fetchSuggestionsRequest() {
  return {
    type: SUGGESTIONS_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchSuggestionsSuccess(suggestions) {
  return {
    type: SUGGESTIONS_FETCH_SUCCESS,
    suggestions,
    skipLoading: true,
  };
}

export function fetchSuggestionsFail(error) {
  return {
    type: SUGGESTIONS_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
}

export const dismissSuggestion = accountId => (dispatch) => {
  dispatch({
    type: SUGGESTIONS_DISMISS,
    id: accountId,
  });

  api().delete(`/api/v1/suggestions/${accountId}`).catch(() => {});
};
