import { Map as ImmutableMap, fromJS } from 'immutable';
import {
  IDENTITY_PROOFS_ACCOUNT_FETCH_REQUEST,
  IDENTITY_PROOFS_ACCOUNT_FETCH_SUCCESS,
  IDENTITY_PROOFS_ACCOUNT_FETCH_FAIL,
} from '../actions/identity_proofs';

const initialState = ImmutableMap();

export default function identityProofsReducer(state = initialState, action) {
  switch(action.type) {
  case IDENTITY_PROOFS_ACCOUNT_FETCH_REQUEST:
    return state.set('isLoading', true);
  case IDENTITY_PROOFS_ACCOUNT_FETCH_FAIL:
    return state.set('isLoading', false);
  case IDENTITY_PROOFS_ACCOUNT_FETCH_SUCCESS:
    return state.update(identity_proofs => identity_proofs.withMutations(map => {
      map.set('isLoading', false);
      map.set('loaded', true);
      map.set(action.accountId, fromJS(action.identity_proofs));
    }));
  default:
    return state;
  }
};
