import api from '../api'

export const SEARCH_CHANGE            = 'SEARCH_CHANGE';
export const SEARCH_SUGGESTIONS_CLEAR = 'SEARCH_SUGGESTIONS_CLEAR';
export const SEARCH_SUGGESTIONS_READY = 'SEARCH_SUGGESTIONS_READY';
export const SEARCH_RESET             = 'SEARCH_RESET';

export function changeSearch(value) {
  return {
    type: SEARCH_CHANGE,
    value
  };
};

export function clearSearchSuggestions() {
  return {
    type: SEARCH_SUGGESTIONS_CLEAR
  };
};

export function readySearchSuggestions(value, accounts) {
  return {
    type: SEARCH_SUGGESTIONS_READY,
    value,
    accounts
  };
};

export function fetchSearchSuggestions(value) {
  return (dispatch, getState) => {
    if (getState().getIn(['search', 'loaded_value']) === value) {
      return;
    }

    api(getState).get('/api/v1/accounts/search', {
      params: {
        q: value,
        resolve: true,
        limit: 4
      }
    }).then(response => {
      dispatch(readySearchSuggestions(value, response.data));
    });
  };
};

export function resetSearch() {
  return {
    type: SEARCH_RESET
  };
};
