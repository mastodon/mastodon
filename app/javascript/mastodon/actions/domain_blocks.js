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

export const DOMAIN_BLOCKS_EXPAND_REQUEST = 'DOMAIN_BLOCKS_EXPAND_REQUEST';
export const DOMAIN_BLOCKS_EXPAND_SUCCESS = 'DOMAIN_BLOCKS_EXPAND_SUCCESS';
export const DOMAIN_BLOCKS_EXPAND_FAIL    = 'DOMAIN_BLOCKS_EXPAND_FAIL';

export function blockDomain(domain) {
  return (dispatch, getState) => {
    dispatch(blockDomainRequest(domain));

    api(getState).post('/api/v1/domain_blocks', { domain }).then(() => {
      const at_domain = '@' + domain;
      const accounts = getState().get('accounts').filter(item => item.get('acct').endsWith(at_domain)).valueSeq().map(item => item.get('id'));
      dispatch(blockDomainSuccess(domain, accounts));
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

export function blockDomainSuccess(domain, accounts) {
  return {
    type: DOMAIN_BLOCK_SUCCESS,
    domain,
    accounts,
  };
};

export function blockDomainFail(domain, error) {
  return {
    type: DOMAIN_BLOCK_FAIL,
    domain,
    error,
  };
};

export function unblockDomain(domain) {
  return (dispatch, getState) => {
    dispatch(unblockDomainRequest(domain));

    api(getState).delete('/api/v1/domain_blocks', { params: { domain } }).then(() => {
      const at_domain = '@' + domain;
      const accounts = getState().get('accounts').filter(item => item.get('acct').endsWith(at_domain)).valueSeq().map(item => item.get('id'));
      dispatch(unblockDomainSuccess(domain, accounts));
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

export function unblockDomainSuccess(domain, accounts) {
  return {
    type: DOMAIN_UNBLOCK_SUCCESS,
    domain,
    accounts,
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

    api(getState).get('/api/v1/domain_blocks').then(response => {
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

export function expandDomainBlocks() {
  return (dispatch, getState) => {
    const url = getState().getIn(['domain_lists', 'blocks', 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandDomainBlocksRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandDomainBlocksSuccess(response.data, next ? next.uri : null));
    }).catch(err => {
      dispatch(expandDomainBlocksFail(err));
    });
  };
};

export function expandDomainBlocksRequest() {
  return {
    type: DOMAIN_BLOCKS_EXPAND_REQUEST,
  };
};

export function expandDomainBlocksSuccess(domains, next) {
  return {
    type: DOMAIN_BLOCKS_EXPAND_SUCCESS,
    domains,
    next,
  };
};

export function expandDomainBlocksFail(error) {
  return {
    type: DOMAIN_BLOCKS_EXPAND_FAIL,
    error,
  };
};
