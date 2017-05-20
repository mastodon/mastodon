import {
  ACCOUNT_FOLLOW_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_UNBLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
  ACCOUNT_UNMUTE_SUCCESS,
  RELATIONSHIPS_FETCH_SUCCESS,
} from '../actions/accounts';
import {
  DOMAIN_BLOCK_SUCCESS,
  DOMAIN_UNBLOCK_SUCCESS,
} from '../actions/domain_blocks';
import Immutable from 'immutable';

const normalizeRelationship = (state, relationship) => state.set(relationship.id, Immutable.fromJS(relationship));

const normalizeRelationships = (state, relationships) => {
  relationships.forEach(relationship => {
    state = normalizeRelationship(state, relationship);
  });

  return state;
};

const initialState = Immutable.Map();

export default function relationships(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_FOLLOW_SUCCESS:
  case ACCOUNT_UNFOLLOW_SUCCESS:
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_UNBLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
  case ACCOUNT_UNMUTE_SUCCESS:
    return normalizeRelationship(state, action.relationship);
  case RELATIONSHIPS_FETCH_SUCCESS:
    return normalizeRelationships(state, action.relationships);
  case DOMAIN_BLOCK_SUCCESS:
    return state.setIn([action.accountId, 'domain_blocking'], true);
  case DOMAIN_UNBLOCK_SUCCESS:
    return state.setIn([action.accountId, 'domain_blocking'], false);
  default:
    return state;
  }
};
