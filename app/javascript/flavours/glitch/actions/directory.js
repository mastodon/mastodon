import api from 'flavours/glitch/util/api';
import { importFetchedAccounts } from './importer';
import { fetchRelationships } from './accounts';

export const DIRECTORY_FETCH_REQUEST = 'DIRECTORY_FETCH_REQUEST';
export const DIRECTORY_FETCH_SUCCESS = 'DIRECTORY_FETCH_SUCCESS';
export const DIRECTORY_FETCH_FAIL    = 'DIRECTORY_FETCH_FAIL';

export const DIRECTORY_EXPAND_REQUEST = 'DIRECTORY_EXPAND_REQUEST';
export const DIRECTORY_EXPAND_SUCCESS = 'DIRECTORY_EXPAND_SUCCESS';
export const DIRECTORY_EXPAND_FAIL    = 'DIRECTORY_EXPAND_FAIL';

export const fetchDirectory = params => (dispatch, getState) => {
  dispatch(fetchDirectoryRequest());

  api(getState).get('/api/v1/directory', { params: { ...params, limit: 20 } }).then(({ data }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(fetchDirectorySuccess(data));
    dispatch(fetchRelationships(data.map(x => x.id)));
  }).catch(error => dispatch(fetchDirectoryFail(error)));
};

export const fetchDirectoryRequest = () => ({
  type: DIRECTORY_FETCH_REQUEST,
});

export const fetchDirectorySuccess = accounts => ({
  type: DIRECTORY_FETCH_SUCCESS,
  accounts,
});

export const fetchDirectoryFail = error => ({
  type: DIRECTORY_FETCH_FAIL,
  error,
});

export const expandDirectory = params => (dispatch, getState) => {
  dispatch(expandDirectoryRequest());

  const loadedItems = getState().getIn(['user_lists', 'directory', 'items']).size;

  api(getState).get('/api/v1/directory', { params: { ...params, offset: loadedItems, limit: 20 } }).then(({ data }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(expandDirectorySuccess(data));
    dispatch(fetchRelationships(data.map(x => x.id)));
  }).catch(error => dispatch(expandDirectoryFail(error)));
};

export const expandDirectoryRequest = () => ({
  type: DIRECTORY_EXPAND_REQUEST,
});

export const expandDirectorySuccess = accounts => ({
  type: DIRECTORY_EXPAND_SUCCESS,
  accounts,
});

export const expandDirectoryFail = error => ({
  type: DIRECTORY_EXPAND_FAIL,
  error,
});
