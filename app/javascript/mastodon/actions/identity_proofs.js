import api from '../api';

export const IDENTITY_PROOFS_ACCOUNT_FETCH_REQUEST = 'IDENTITY_PROOFS_ACCOUNT_FETCH_REQUEST';
export const IDENTITY_PROOFS_ACCOUNT_FETCH_SUCCESS = 'IDENTITY_PROOFS_ACCOUNT_FETCH_SUCCESS';
export const IDENTITY_PROOFS_ACCOUNT_FETCH_FAIL    = 'IDENTITY_PROOFS_ACCOUNT_FETCH_FAIL';

export const fetchAccountIdentityProofs = accountId => (dispatch, getState) => {
  dispatch(fetchAccountIdentityProofsRequest(accountId));

  api(getState).get(`/api/v1/accounts/${accountId}/identity_proofs`)
    .then(({ data }) => dispatch(fetchAccountIdentityProofsSuccess(accountId, data)))
    .catch(err => dispatch(fetchAccountIdentityProofsFail(accountId, err)));
};

export const fetchAccountIdentityProofsRequest = id => ({
  type: IDENTITY_PROOFS_ACCOUNT_FETCH_REQUEST,
  id,
});

export const fetchAccountIdentityProofsSuccess = (accountId, identity_proofs) => ({
  type: IDENTITY_PROOFS_ACCOUNT_FETCH_SUCCESS,
  accountId,
  identity_proofs,
});

export const fetchAccountIdentityProofsFail = (accountId, err) => ({
  type: IDENTITY_PROOFS_ACCOUNT_FETCH_FAIL,
  accountId,
  err,
});
