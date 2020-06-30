import {
  ACCOUNT_FOLLOW_SUCCESS,
  ACCOUNT_UNFOLLOW_SUCCESS,
  ACCOUNT_BLOCK_SUCCESS,
  ACCOUNT_UNBLOCK_SUCCESS,
  ACCOUNT_MUTE_SUCCESS,
  ACCOUNT_UNMUTE_SUCCESS,
  ACCOUNT_PIN_SUCCESS,
  ACCOUNT_UNPIN_SUCCESS,
  RELATIONSHIPS_FETCH_SUCCESS,
} from 'flavours/glitch/actions/accounts';
import {
  DOMAIN_BLOCK_SUCCESS,
  DOMAIN_UNBLOCK_SUCCESS,
} from 'flavours/glitch/actions/domain_blocks';
import {
  ACCOUNT_NOTE_SUBMIT_SUCCESS,
} from 'flavours/glitch/actions/account_notes';
import { Map as ImmutableMap, fromJS } from 'immutable';

const normalizeRelationship = (state, relationship) => state.set(relationship.id, fromJS(relationship));

const normalizeRelationships = (state, relationships) => {
  relationships.forEach(relationship => {
    state = normalizeRelationship(state, relationship);
  });

  return state;
};

const setDomainBlocking = (state, accounts, blocking) => {
  return state.withMutations(map => {
    accounts.forEach(id => {
      map.setIn([id, 'domain_blocking'], blocking);
    });
  });
};

const initialState = ImmutableMap();

export default function relationships(state = initialState, action) {
  switch(action.type) {
  case ACCOUNT_FOLLOW_SUCCESS:
  case ACCOUNT_UNFOLLOW_SUCCESS:
  case ACCOUNT_BLOCK_SUCCESS:
  case ACCOUNT_UNBLOCK_SUCCESS:
  case ACCOUNT_MUTE_SUCCESS:
  case ACCOUNT_UNMUTE_SUCCESS:
  case ACCOUNT_PIN_SUCCESS:
  case ACCOUNT_UNPIN_SUCCESS:
  case ACCOUNT_NOTE_SUBMIT_SUCCESS:
    return normalizeRelationship(state, action.relationship);
  case RELATIONSHIPS_FETCH_SUCCESS:
    return normalizeRelationships(state, action.relationships);
  case DOMAIN_BLOCK_SUCCESS:
    return setDomainBlocking(state, action.accounts, true);
  case DOMAIN_UNBLOCK_SUCCESS:
    return setDomainBlocking(state, action.accounts, false);
  default:
    return state;
  }
};
