import api, { getLinks } from '../api'
import Immutable from 'immutable';

export const DOMAIN_BLOCK_REQUEST = 'DOMAIN_BLOCK_REQUEST';
export const DOMAIN_BLOCK_SUCCESS = 'DOMAIN_BLOCK_SUCCESS';
export const DOMAIN_BLOCK_FAIL    = 'DOMAIN_BLOCK_FAIL';

export const DOMAIN_UNBLOCK_REQUEST = 'DOMAIN_UNBLOCK_REQUEST';
export const DOMAIN_UNBLOCK_SUCCESS = 'DOMAIN_UNBLOCK_SUCCESS';
export const DOMAIN_UNBLOCK_FAIL    = 'DOMAIN_UNBLOCK_FAIL';

export function blockDomain(domain) {
  return (dispatch, getState) => {
    dispatch(blockDomainRequest(domain));

    api(getState).post(`/api/v1/domains/block?domain=${domain}`).then(response => {
      // Pass in entire statuses map so we can use it to filter stuff in different parts of the reducers
      dispatch(blockDomainSuccess(response.data));
    }).catch(error => {
      dispatch(blockDomainFail(domain, error));
    });
  };
};

export function unblockDomain(domain) {
  return (dispatch, getState) => {
    dispatch(unblockDomainRequest(domain));

    api(getState).post(`/api/v1/domains/unblock?domain=${domain}`).then(response => {
      dispatch(unblockDomainSuccess(response.data));
    }).catch(error => {
      dispatch(unblockDomainFail(domain, error));
    });
  };
};

export function blockDomainRequest(id) {
  return {
    type: DOMAIN_BLOCK_REQUEST,
    id
  };
};

export function blockDomainSuccess(blocked_domains) {
  return {
    type: DOMAIN_BLOCK_SUCCESS,
    blocked_domains: blocked_domains
  };
};

export function blockDomainFail(error) {
  return {
    type: DOMAIN_BLOCK_FAIL,
    error
  };
};

export function unblockDomainRequest(id) {
  return {
    type: DOMAIN_UNBLOCK_REQUEST,
    id
  };
};

export function unblockDomainSuccess(blocked_domains) {
  return {
    type: DOMAIN_UNBLOCK_SUCCESS,
    blocked_domains: blocked_domains
  };
};

export function unblockDomainFail(error) {
  return {
    type: DOMAIN_UNBLOCK_FAIL,
    error
  };
};