import {
  GROUP_MEMBERSHIPS_FETCH_REQUEST,
  GROUP_MEMBERSHIPS_FETCH_FAIL,
  GROUP_MEMBERSHIPS_FETCH_SUCCESS,
  GROUP_MEMBERSHIPS_EXPAND_REQUEST,
  GROUP_MEMBERSHIPS_EXPAND_FAIL,
  GROUP_MEMBERSHIPS_EXPAND_SUCCESS,
  GROUP_PROMOTE_SUCCESS,
  GROUP_DEMOTE_SUCCESS,
  GROUP_KICK_SUCCESS,
  GROUP_BLOCK_SUCCESS,
} from '../actions/groups';
import { Map as ImmutableMap, OrderedSet } from 'immutable';

const initialListState = ImmutableMap({
  next: null,
  isLoading: false,
  items: OrderedSet(),
});

const initialState = ImmutableMap({
  'admin': ImmutableMap({}),
  'moderator': ImmutableMap({}),
  'user': ImmutableMap({}),
});

const normalizeList = (state, path, memberships, next) => {
  return state.setIn(path, ImmutableMap({
    next,
    items: OrderedSet(memberships.map(item => item.account.id)),
    isLoading: false,
  }));
};

const appendToList = (state, path, memberships, next) => {
  return state.updateIn(path, map => {
    return map.set('next', next).set('isLoading', false).update('items', list => list.concat(memberships.map(item => item.account.id)));
  });
};

const updateLists = (state, groupId, memberships) => {
  const updateList = (state, role, membership) => {
    if (role === membership.role) {
      return state.updateIn([role, groupId], map => map.update('items', set => set.add(membership.account.id)));
    } else {
      return state.updateIn([role, groupId], map => map.update('items', set => set.delete(membership.account.id)));
    }
  };

  memberships.forEach(membership => {
    state = updateList(state, 'admin', membership);
    state = updateList(state, 'moderator', membership);
    state = updateList(state, 'user', membership);
  });

  return state;
};

const removeFromList = (state, path, accountId) => {
  return state.updateIn(path, map => {
    return map.update('items', set => set.delete(accountId));
  });
};

export default function group_memberships(state = initialState, action) {
  switch(action.type) {
  case GROUP_MEMBERSHIPS_FETCH_REQUEST:
  case GROUP_MEMBERSHIPS_EXPAND_REQUEST:
    return state.updateIn([action.role, action.id], map => (map || initialListState).set('isLoading', true));
  case GROUP_MEMBERSHIPS_FETCH_FAIL:
  case GROUP_MEMBERSHIPS_EXPAND_FAIL:
    return state.updateIn([action.role, action.id], map => (map || initialListState).set('isLoading', false));
  case GROUP_MEMBERSHIPS_FETCH_SUCCESS:
    return normalizeList(state, [action.role, action.id], action.memberships, action.next);
  case GROUP_MEMBERSHIPS_EXPAND_SUCCESS:
    return appendToList(state, [action.role, action.id], action.memberships, action.next);
  case GROUP_PROMOTE_SUCCESS:
  case GROUP_DEMOTE_SUCCESS:
    return updateLists(state, action.groupId, action.memberships);
  case GROUP_KICK_SUCCESS:
  case GROUP_BLOCK_SUCCESS:
    state = removeFromList(state, ['admin', action.groupId], action.accountId);
    state = removeFromList(state, ['moderator', action.groupId], action.accountId);
    state = removeFromList(state, ['user', action.groupId], action.accountId);
    return state;
  default:
    return state;
  }
};
