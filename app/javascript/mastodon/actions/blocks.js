import api, { getLinks } from '../api';
import { fetchRelationships } from './accounts';
import { importFetchedAccounts } from './importer';
import { openModal } from './modal';

export const BLOCKS_FETCH_REQUEST = 'BLOCKS_FETCH_REQUEST';
export const BLOCKS_FETCH_SUCCESS = 'BLOCKS_FETCH_SUCCESS';
export const BLOCKS_FETCH_FAIL = 'BLOCKS_FETCH_FAIL';

export const BLOCKS_EXPAND_REQUEST = 'BLOCKS_EXPAND_REQUEST';
export const BLOCKS_EXPAND_SUCCESS = 'BLOCKS_EXPAND_SUCCESS';
export const BLOCKS_EXPAND_FAIL = 'BLOCKS_EXPAND_FAIL';

export const BLOCKS_INIT_MODAL = 'BLOCKS_INIT_MODAL';

export const SYNCHROS_FETCH_SUCCESS = "SYNCHROS_FETCH_SUCCESS";
export const SYNCHROS_FETCH_FAIL = "SYNCHROS_FETCH_FAIL ";
export const SYNCHROS_EXPAND_REQUEST = "SYNCHROS_EXPAND_REQUEST";
export const SYNCHROS_EXPAND_SUCCESS = "SYNCHROS_EXPAND_SUCCESS";
export const SYNCHROS_EXPAND_FAIL = "SYNCHROS_EXPAND_FAIL";

export function fetchBlocks(id) {
  return (dispatch, getState) => {
    dispatch(fetchBlocksRequest());

    api(getState).get(`/api/v1/blocks/${id}`).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedAccounts(response.data));
      dispatch(fetchBlocksSuccess(response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => dispatch(fetchBlocksFail(error)));
  };
};

export function fetchBlocksRequest(id) {
  return {
    type: BLOCKS_FETCH_REQUEST,
    id
  };
};

export function fetchBlocksSuccess(accounts, next) {
  return {
    type: BLOCKS_FETCH_SUCCESS,
    accounts,
    next,
  };
};

export function fetchBlocksFail(error) {
  return {
    type: BLOCKS_FETCH_FAIL,
    error,
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
      dispatch(importFetchedAccounts(response.data));
      dispatch(expandBlocksSuccess(response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => dispatch(expandBlocksFail(error)));
  };
};

export function expandBlocksRequest() {
  return {
    type: BLOCKS_EXPAND_REQUEST,
  };
};

export function expandBlocksSuccess(accounts, next) {
  return {
    type: BLOCKS_EXPAND_SUCCESS,
    accounts,
    next,
  };
};

export function expandBlocksFail(error) {
  return {
    type: BLOCKS_EXPAND_FAIL,
    error,
  };
};

export function fetchSynchroBlocks(id) {
  return (dispatch, getState) => {
    dispatch(fetchBlocksRequest());

    api(getState).get(`/api/v1/blocks/${id}`).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedAccounts(response.data));
      dispatch(fetchSynchroBlocksSuccess(response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => dispatch(fetchSynchroBlocksFail(error)));
  };
};

export function fetchSynchroBlocksRequest(id) {
  return {
    type: SYNCHROS_FETCH_REQUEST,
    id
  };
};

export function fetchSynchroBlocksSuccess(accounts, next) {
  return {
    type: SYNCHROS_FETCH_SUCCESS,
    accounts,
    next,
  };
};

export function fetchSynchroBlocksFail(error) {
  return {
    type: SYNCHROS_FETCH_FAIL,
    error,
  };
};

export function expandSynchroBlocks() {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'blocks', 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandBlocksRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedAccounts(response.data));
      dispatch(expandSynchroBlocksSuccess(response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => dispatch(expandSynchroBlocksFail(error)));
  };
};

export function expandSynchroBlocksRequest() {
  return {
    type: SYNCHROS_EXPAND_REQUEST,
  };
};

export function expandSynchroBlocksSuccess(accounts, next) {
  return {
    type: SYNCHROS_EXPAND_SUCCESS,
    accounts,
    next,
  };
};

export function expandSynchroBlocksFail(error) {
  return {
    type: SYNCHROS_EXPAND_FAIL,
    error,
  };
};

export function initBlockModal(account) {
  return dispatch => {
    dispatch({
      type: BLOCKS_INIT_MODAL,
      account,
    });

    dispatch(openModal('BLOCK'));
  };
}
