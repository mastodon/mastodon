import api from '../api';

export const SUGGESTIONS_FETCH_REQUEST = 'SUGGESTIONS_FETCH_REQUEST';
export const SUGGESTIONS_FETCH_SUCCESS = 'SUGGESTIONS_FETCH_SUCCESS';
export const SUGGESTIONS_FETCH_FAIL    = 'SUGGESTIONS_FETCH_FAIL';

export function fetchSuggestions() {
  return (dispatch, getState) => {
    api(getState).get('/api/v1/accounts/suggestions').then(response => {
      console.log(response.data);
    }).catch(error => {
      console.error(error);
    });
  };
};
