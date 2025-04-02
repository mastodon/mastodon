import api, { getLinks } from '../api';

import { blockDomainSuccess, unblockDomainSuccess } from "./domain_blocks_typed";
import { openModal } from './modal';


export * from "./domain_blocks_typed";

export const DOMAIN_BLOCK_REQUEST = 'DOMAIN_BLOCK_REQUEST';
export const DOMAIN_BLOCK_FAIL    = 'DOMAIN_BLOCK_FAIL';

export const DOMAIN_UNBLOCK_REQUEST = 'DOMAIN_UNBLOCK_REQUEST';
export const DOMAIN_UNBLOCK_FAIL    = 'DOMAIN_UNBLOCK_FAIL';

export function blockDomain(domain) {
  return (dispatch, getState) => {
    dispatch(blockDomainRequest(domain));

    api().post('/api/v1/domain_blocks', { domain }).then(() => {
      const at_domain = '@' + domain;
      const accounts = getState().get('accounts').filter(item => item.get('acct').endsWith(at_domain)).valueSeq().map(item => item.get('id'));

      dispatch(blockDomainSuccess({ domain, accounts }));
    }).catch(err => {
      dispatch(blockDomainFail(domain, err));
    });
  };
}

export function blockDomainRequest(domain) {
  return {
    type: DOMAIN_BLOCK_REQUEST,
    domain,
  };
}

export function blockDomainFail(domain, error) {
  return {
    type: DOMAIN_BLOCK_FAIL,
    domain,
    error,
  };
}

export function unblockDomain(domain) {
  return (dispatch, getState) => {
    dispatch(unblockDomainRequest(domain));

    api().delete('/api/v1/domain_blocks', { params: { domain } }).then(() => {
      const at_domain = '@' + domain;
      const accounts = getState().get('accounts').filter(item => item.get('acct').endsWith(at_domain)).valueSeq().map(item => item.get('id'));
      dispatch(unblockDomainSuccess({ domain, accounts }));
    }).catch(err => {
      dispatch(unblockDomainFail(domain, err));
    });
  };
}

export function unblockDomainRequest(domain) {
  return {
    type: DOMAIN_UNBLOCK_REQUEST,
    domain,
  };
}

export function unblockDomainFail(domain, error) {
  return {
    type: DOMAIN_UNBLOCK_FAIL,
    domain,
    error,
  };
}

export const initDomainBlockModal = account => dispatch => dispatch(openModal({
  modalType: 'DOMAIN_BLOCK',
  modalProps: {
    domain: account.get('acct').split('@')[1],
    acct: account.get('acct'),
    accountId: account.get('id'),
  },
}));
