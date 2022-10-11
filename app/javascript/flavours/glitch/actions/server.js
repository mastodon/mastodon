import api from '../api';
import { importFetchedAccount } from './importer';

export const SERVER_FETCH_REQUEST = 'Server_FETCH_REQUEST';
export const SERVER_FETCH_SUCCESS = 'Server_FETCH_SUCCESS';
export const SERVER_FETCH_FAIL    = 'Server_FETCH_FAIL';

export const fetchServer = () => (dispatch, getState) => {
  dispatch(fetchServerRequest());

  api(getState)
    .get('/api/v2/instance').then(({ data }) => {
      if (data.contact.account) dispatch(importFetchedAccount(data.contact.account));
      dispatch(fetchServerSuccess(data));
    }).catch(err => dispatch(fetchServerFail(err)));
};

const fetchServerRequest = () => ({
  type: SERVER_FETCH_REQUEST,
});

const fetchServerSuccess = server => ({
  type: SERVER_FETCH_SUCCESS,
  server,
});

const fetchServerFail = error => ({
  type: SERVER_FETCH_FAIL,
  error,
});
