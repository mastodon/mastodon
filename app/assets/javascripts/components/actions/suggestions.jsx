import api from '../api';

export const SUGGESTIONS_FETCH_REQUEST = 'SUGGESTIONS_FETCH_REQUEST';
export const SUGGESTIONS_FETCH_SUCCESS = 'SUGGESTIONS_FETCH_SUCCESS';
export const SUGGESTIONS_FETCH_FAIL    = 'SUGGESTIONS_FETCH_FAIL';

export function fetchSuggestions() {
  return (dispatch, getState) => {
    dispatch(fetchSuggestionsRequest());

    api(getState).get('/api/v1/accounts/suggestions').then(response => {
      dispatch(fetchSuggestionsSuccess(response.data));
    }).catch(error => {
      dispatch(fetchSuggestionsFail(error));
    });
  };
};

export function fetchSuggestionsRequest() {
  return {
    type: SUGGESTIONS_FETCH_REQUEST
  };
};

export function fetchSuggestionsSuccess(suggestions) {
  return {
    type: SUGGESTIONS_FETCH_SUCCESS,
    suggestions: suggestions
  };
};

export function fetchSuggestionsFail(error) {
  return {
    type: SUGGESTIONS_FETCH_FAIL,
    error: error
  };
};
