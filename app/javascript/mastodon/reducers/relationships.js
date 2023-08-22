import { Map as ImmutableMap, fromJS } from 'immutable';

import {
  submitAccountNote,
} from '../actions/account_notes';
import {
  followAccountSuccess, unfollowAccountSuccess, authorizeFollowRequestSuccess, rejectFollowRequestSuccess, followAccountRequest, followAccountFail, unfollowAccountRequest, unfollowAccountFail, blockAccountSuccess, unblockAccountSuccess, muteAccountSuccess, unmuteAccountSuccess, pinAccountSuccess, unpinAccountSuccess, fetchRelationshipsSuccess
} from '../actions/accounts';
import {
  blockDomainSuccess,
  unblockDomainSuccess,
} from '../actions/domain_blocks';
import {
  notificationsUpdate,
} from '../actions/notifications';


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
  case authorizeFollowRequestSuccess.type:
    return state.setIn([action.id, 'followed_by'], true).setIn([action.payload.id, 'requested_by'], false);
  case rejectFollowRequestSuccess.type:
    return state.setIn([action.id, 'followed_by'], false).setIn([action.payload.id, 'requested_by'], false);
  case notificationsUpdate.type:
    return action.payload.notification.type === 'follow_request' ? state.setIn([action.payload.notification.account.id, 'requested_by'], true) : state;
  case followAccountRequest.type:
    return state.getIn([action.payload.id, 'following']) ? state : state.setIn([action.payload.id, action.payload.locked ? 'requested' : 'following'], true);
  case followAccountFail.type:
    return state.setIn([action.payload.id, action.payload.locked ? 'requested' : 'following'], false);
  case unfollowAccountRequest.type:
    return state.setIn([action.payload.id, 'following'], false);
  case unfollowAccountFail.type:
    return state.setIn([action.payload.id, 'following'], true);
  case followAccountSuccess.type:
  case unfollowAccountSuccess.type:
  case blockAccountSuccess.type:
  case unblockAccountSuccess.type:
  case muteAccountSuccess.type:
  case unmuteAccountSuccess.type:
  case pinAccountSuccess.type:
  case unpinAccountSuccess.type:
  case submitAccountNote.fulfilled:
    return normalizeRelationship(state, action.payload.relationship);
  case fetchRelationshipsSuccess.type:
    return normalizeRelationships(state, action.payload.relationships);
  case blockDomainSuccess.type:
    return setDomainBlocking(state, action.payload.accounts, true);
  case unblockDomainSuccess.type:
    return setDomainBlocking(state, action.payload.accounts, false);
  default:
    return state;
  }
}
