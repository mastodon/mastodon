import api, { getLinks } from '../api';

export const DOMAIN_BLOCK_REQUEST = 'DOMAIN_BLOCK_REQUEST';
export const DOMAIN_BLOCK_SUCCESS = 'DOMAIN_BLOCK_SUCCESS';
export const DOMAIN_BLOCK_FAIL    = 'DOMAIN_BLOCK_FAIL';

export const DOMAIN_UNBLOCK_REQUEST = 'DOMAIN_UNBLOCK_REQUEST';
export const DOMAIN_UNBLOCK_SUCCESS = 'DOMAIN_UNBLOCK_SUCCESS';
export const DOMAIN_UNBLOCK_FAIL    = 'DOMAIN_UNBLOCK_FAIL';

export const DOMAIN_BLOCKS_FETCH_REQUEST = 'DOMAIN_BLOCKS_FETCH_REQUEST';
export const DOMAIN_BLOCKS_FETCH_SUCCESS = 'DOMAIN_BLOCKS_FETCH_SUCCESS';
export const DOMAIN_BLOCKS_FETCH_FAIL    = 'DOMAIN_BLOCKS_FETCH_FAIL';

export function blockDomain(domain, accountId) {
  return (dispatch, getState) => {
    dispatch(blockDomainRequest(domain));

    api(getState).post('/api/v1/domain_blocks', { domain }).then(response => {
      dispatch(blockDomainSuccess(domain, accountId));
    }).catch(err => {
      dispatch(blockDomainFail(domain, err));
    });
  };
};

export function blockDomainRequest(domain) {
  return {
    type: DOMAIN_BLOCK_REQUEST,
    domain,
  };
};

export function blockDomainSuccess(domain, accountId) {
  return {
    type: DOMAIN_BLOCK_SUCCESS,
    domain,
    accountId,
  };
};

export function blockDomainFail(domain, error) {
  return {
    type: DOMAIN_BLOCK_FAIL,
    domain,
    error,
  };
};

export function unblockDomain(domain, accountId) {
  return (dispatch, getState) => {
    dispatch(unblockDomainRequest(domain));

    api(getState).delete('/api/v1/domain_blocks', { params: { domain } }).then(response => {
      dispatch(unblockDomainSuccess(domain, accountId));
    }).catch(err => {
      dispatch(unblockDomainFail(domain, err));
    });
  };
};

export function unblockDomainRequest(domain) {
  return {
    type: DOMAIN_UNBLOCK_REQUEST,
    domain,
  };
};

export function unblockDomainSuccess(domain, accountId) {
  return {
    type: DOMAIN_UNBLOCK_SUCCESS,
    domain,
    accountId,
  };
};

export function unblockDomainFail(domain, error) {
  return {
    type: DOMAIN_UNBLOCK_FAIL,
    domain,
    error,
  };
};

export function fetchDomainBlocks() {
  return (dispatch, getState) => {
    dispatch(fetchDomainBlocksRequest());

    api(getState).get().then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(fetchDomainBlocksSuccess(response.data, next ? next.uri : null));
    }).catch(err => {
      dispatch(fetchDomainBlocksFail(err));
    });
  };
};

export function fetchDomainBlocksRequest() {
  return {
    type: DOMAIN_BLOCKS_FETCH_REQUEST,
  };
};

export function fetchDomainBlocksSuccess(domains, next) {
  return {
    type: DOMAIN_BLOCKS_FETCH_SUCCESS,
    domains,
    next,
  };
};

export function fetchDomainBlocksFail(error) {
  return {
    type: DOMAIN_BLOCKS_FETCH_FAIL,
    error,
  };
};
