import api, { getLinks } from '../api'
import { fetchRelationships } from './accounts';

export const BLOCKS_FETCH_REQUEST = 'BLOCKS_FETCH_REQUEST';
export const BLOCKS_FETCH_SUCCESS = 'BLOCKS_FETCH_SUCCESS';
export const BLOCKS_FETCH_FAIL    = 'BLOCKS_FETCH_FAIL';

export const BLOCKS_EXPAND_REQUEST = 'BLOCKS_EXPAND_REQUEST';
export const BLOCKS_EXPAND_SUCCESS = 'BLOCKS_EXPAND_SUCCESS';
export const BLOCKS_EXPAND_FAIL    = 'BLOCKS_EXPAND_FAIL';

export function fetchBlocks() {
  return (dispatch, getState) => {
    dispatch(fetchBlocksRequest());

    api(getState).get('/api/v1/blocks').then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(fetchBlocksSuccess(response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => dispatch(fetchBlocksFail(error)));
  };
};

export function fetchBlocksRequest() {
  return {
    type: BLOCKS_FETCH_REQUEST
  };
};

export function fetchBlocksSuccess(accounts, next) {
  return {
    type: BLOCKS_FETCH_SUCCESS,
    accounts,
    next
  };
};

export function fetchBlocksFail(error) {
  return {
    type: BLOCKS_FETCH_FAIL,
    error
  };
};

export function expandBlocks() {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'blocks', 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandBlocksRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandBlocksSuccess(response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => dispatch(expandBlocksFail(error)));
  };
};

export function expandBlocksRequest() {
  return {
    type: BLOCKS_EXPAND_REQUEST
  };
};

export function expandBlocksSuccess(accounts, next) {
  return {
    type: BLOCKS_EXPAND_SUCCESS,
    accounts,
    next
  };
};

export function expandBlocksFail(error) {
  return {
    type: BLOCKS_EXPAND_FAIL,
    error
  };
};
