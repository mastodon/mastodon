import {
  GROUP_DELETE_SUCCESS,
  GROUP_RELATIONSHIPS_FETCH_SUCCESS,
  GROUP_JOIN_REQUEST,
  GROUP_JOIN_SUCCESS,
  GROUP_JOIN_FAIL,
  GROUP_LEAVE_REQUEST,
  GROUP_LEAVE_SUCCESS,
  GROUP_LEAVE_FAIL,
} from '../actions/groups';
import { Map as ImmutableMap, fromJS } from 'immutable';

const normalizeRelationship = (state, relationship) => state.set(relationship.id, fromJS(relationship));

const normalizeRelationships = (state, relationships) => {
  relationships.forEach(relationship => {
    state = normalizeRelationship(state, relationship);
  });

  return state;
};

const initialState = ImmutableMap();

export default function relationships(state = initialState, action) {
  switch(action.type) {
  case GROUP_DELETE_SUCCESS:
    return state.delete(action.id);
  case GROUP_JOIN_REQUEST:
    return state.getIn([action.id, 'member']) ? state : state.setIn([action.id, action.locked ? 'requested' : 'member'], true);
  case GROUP_JOIN_FAIL:
    return state.setIn([action.id, action.locked ? 'requested' : 'member'], false);
  case GROUP_LEAVE_REQUEST:
    return state.setIn([action.id, 'member'], false);
  case GROUP_LEAVE_FAIL:
    return state.setIn([action.id, 'member'], true);
  case GROUP_JOIN_SUCCESS:
  case GROUP_LEAVE_SUCCESS:
    return normalizeRelationship(state, action.relationship);
  case GROUP_RELATIONSHIPS_FETCH_SUCCESS:
    return normalizeRelationships(state, action.relationships);
  default:
    return state;
  }
};
