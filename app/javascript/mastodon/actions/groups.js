import api from '../api';
import { importFetchedGroups } from './importer';
import { deleteFromTimelines } from './timelines';

export const GROUP_FETCH_REQUEST = 'GROUP_FETCH_REQUEST';
export const GROUP_FETCH_SUCCESS = 'GROUP_FETCH_SUCCESS';
export const GROUP_FETCH_FAIL    = 'GROUP_FETCH_FAIL';

export const GROUPS_FETCH_REQUEST = 'GROUPS_FETCH_REQUEST';
export const GROUPS_FETCH_SUCCESS = 'GROUPS_FETCH_SUCCESS';
export const GROUPS_FETCH_FAIL    = 'GROUPS_FETCH_FAIL';

export const GROUP_RELATIONSHIPS_FETCH_REQUEST = 'GROUP_RELATIONSHIPS_FETCH_REQUEST';
export const GROUP_RELATIONSHIPS_FETCH_SUCCESS = 'GROUP_RELATIONSHIPS_FETCH_SUCCESS';
export const GROUP_RELATIONSHIPS_FETCH_FAIL    = 'GROUP_RELATIONSHIPS_FETCH_FAIL';

export const GROUP_JOIN_REQUEST = 'GROUP_JOIN_REQUEST';
export const GROUP_JOIN_SUCCESS = 'GROUP_JOIN_SUCCESS';
export const GROUP_JOIN_FAIL    = 'GROUP_JOIN_FAIL';

export const GROUP_LEAVE_REQUEST = 'GROUP_LEAVE_REQUEST';
export const GROUP_LEAVE_SUCCESS = 'GROUP_LEAVE_SUCCESS';
export const GROUP_LEAVE_FAIL    = 'GROUP_LEAVE_FAIL';

export const GROUP_DELETE_STATUS_REQUEST = 'GROUP_DELETE_STATUS_REQUEST';
export const GROUP_DELETE_STATUS_SUCCESS = 'GROUP_DELETE_STATUS_SUCCESS';
export const GROUP_DELETE_STATUS_FAIL    = 'GROUP_DELETE_STATUS_FAIL';

export const GROUP_KICK_REQUEST = 'GROUP_KICK_REQUEST';
export const GROUP_KICK_SUCCESS = 'GROUP_KICK_SUCCESS';
export const GROUP_KICK_FAIL    = 'GROUP_KICK_FAIL';

export const GROUP_BLOCK_REQUEST = 'GROUP_BLOCK_REQUEST';
export const GROUP_BLOCK_SUCCESS = 'GROUP_BLOCK_SUCCESS';
export const GROUP_BLOCK_FAIL    = 'GROUP_BLOCK_FAIL';

export const fetchGroup = id => (dispatch, getState) => {
  dispatch(fetchGroupRelationships([id]));
  dispatch(fetchGroupRequest(id));

  api(getState).get(`/api/v1/groups/${id}`)
    .then(({ data }) => {
      dispatch(importFetchedGroups([data]));
      dispatch(fetchGroupSuccess(data));
    })
    .catch(err => dispatch(fetchGroupFail(id, err)));
};

export const fetchGroupRequest = id => ({
  type: GROUP_FETCH_REQUEST,
  id,
});

export const fetchGroupSuccess = group => ({
  type: GROUP_FETCH_SUCCESS,
  group,
});

export const fetchGroupFail = (id, error) => ({
  type: GROUP_FETCH_FAIL,
  id,
  error,
});

export const fetchGroups = () => (dispatch, getState) => {
  dispatch(fetchGroupsRequest());

  api(getState).get('/api/v1/groups')
    .then(({ data }) => {
      dispatch(importFetchedGroups(data));
      dispatch(fetchGroupsSuccess(data));
      dispatch(fetchGroupRelationships(data.map(item => item.id)));
    }).catch(err => dispatch(fetchGroupsFail(err)));
};

export const fetchGroupsRequest = () => ({
  type: GROUPS_FETCH_REQUEST,
});

export const fetchGroupsSuccess = groups => ({
  type: GROUPS_FETCH_SUCCESS,
  groups,
});

export const fetchGroupsFail = (error) => ({
  type: GROUPS_FETCH_FAIL,
  error,
});

export function fetchGroupRelationships(groupIds) {
  return (dispatch, getState) => {
    const state = getState();
    const loadedRelationships = state.get('group_relationships');
    const newGroupIds = groupIds.filter(id => loadedRelationships.get(id, null) === null);

    const signedIn = !!state.getIn(['meta', 'me']);

    if (!signedIn || newGroupIds.length === 0) {
      return;
    }

    dispatch(fetchGroupRelationshipsRequest(newGroupIds));

    api(getState).get(`/api/v1/groups/relationships?${newGroupIds.map(id => `id[]=${id}`).join('&')}`).then(response => {
      dispatch(fetchGroupRelationshipsSuccess(response.data));
    }).catch(error => {
      dispatch(fetchGroupRelationshipsFail(error));
    });
  };
};

export function fetchGroupRelationshipsRequest(ids) {
  return {
    type: GROUP_RELATIONSHIPS_FETCH_REQUEST,
    ids,
    skipLoading: true,
  };
};

export function fetchGroupRelationshipsSuccess(relationships) {
  return {
    type: GROUP_RELATIONSHIPS_FETCH_SUCCESS,
    relationships,
    skipLoading: true,
  };
};

export function fetchGroupRelationshipsFail(error) {
  return {
    type: GROUP_RELATIONSHIPS_FETCH_FAIL,
    error,
    skipLoading: true,
    skipNotFound: true,
  };
};

export function joinGroup(id) {
  return (dispatch, getState) => {
    const locked = getState().getIn(['groups', id, 'locked'], false);

    dispatch(joinGroupRequest(id, locked));

    api(getState).post(`/api/v1/groups/${id}/join`).then(response => {
      dispatch(joinGroupSuccess(response.data));
    }).catch(error => {
      dispatch(joinGroupFail(error, locked));
    });
  };
};

export function leaveGroup(id) {
  return (dispatch, getState) => {
    dispatch(leaveGroupRequest(id));

    api(getState).post(`/api/v1/groups/${id}/leave`).then(response => {
      dispatch(leaveGroupSuccess(response.data));
    }).catch(error => {
      dispatch(leaveGroupFail(error));
    });
  };
};

export function joinGroupRequest(id, locked) {
  return {
    type: GROUP_JOIN_REQUEST,
    id,
    locked,
    skipLoading: true,
  };
};

export function joinGroupSuccess(relationship) {
  return {
    type: GROUP_JOIN_SUCCESS,
    relationship,
    skipLoading: true,
  };
};

export function joinGroupFail(error, locked) {
  return {
    type: GROUP_JOIN_FAIL,
    error,
    locked,
    skipLoading: true,
  };
};

export function leaveGroupRequest(id) {
  return {
    type: GROUP_LEAVE_REQUEST,
    id,
    skipLoading: true,
  };
};

export function leaveGroupSuccess(relationship) {
  return {
    type: GROUP_LEAVE_SUCCESS,
    relationship,
    skipLoading: true,
  };
};

export function leaveGroupFail(error) {
  return {
    type: GROUP_LEAVE_FAIL,
    error,
    skipLoading: true,
  };
};

export function groupDeleteStatus(groupId, statusId) {
  return (dispatch, getState) => {
    dispatch(groupDeleteStatusRequest(groupId, statusId));

    api(getState).delete(`/api/v1/groups/${groupId}/statuses/${statusId}`)
      .then(() => {
        dispatch(deleteFromTimelines(statusId));
        dispatch(groupDeleteStatusSuccess(groupId, statusId));
      }).catch(err => dispatch(groupDeleteStatusFail(groupId, statusId, err)));
  };
};

export function groupDeleteStatusRequest(groupId, statusId) {
  return {
    type: GROUP_DELETE_STATUS_REQUEST,
    groupId,
    statusId,
  };
};

export function groupDeleteStatusSuccess(groupId, statusId) {
  return {
    type: GROUP_DELETE_STATUS_SUCCESS,
    groupId,
    statusId,
  };
};

export function groupDeleteStatusFail(groupId, statusId, error) {
  return {
    type: GROUP_DELETE_STATUS_SUCCESS,
    groupId,
    statusId,
    error,
  };
};

export function groupKick(groupId, accountId) {
  return (dispatch, getState) => {
    dispatch(groupKickRequest(groupId, accountId));

    api(getState).post(`/api/v1/groups/${groupId}/kick`, { account_ids: [accountId] })
      .then(() => dispatch(groupKickSuccess(groupId, accountId)))
      .catch(err => dispatch(groupKickFail(groupId, accountId, err)));
  };
};

export function groupKickRequest(groupId, accountId) {
  return {
    type: GROUP_KICK_REQUEST,
    groupId,
    accountId,
  };
};

export function groupKickSuccess(groupId, accountId) {
  return {
    type: GROUP_KICK_SUCCESS,
    groupId,
    accountId,
  };
};

export function groupKickFail(groupId, accountId, error) {
  return {
    type: GROUP_KICK_SUCCESS,
    groupId,
    accountId,
    error,
  };
};

export function groupBlock(groupId, accountId) {
  return (dispatch, getState) => {
    dispatch(groupBlockRequest(groupId, accountId));

    api(getState).post(`/api/v1/groups/${groupId}/blocks`, { account_ids: [accountId] })
      .then(() => dispatch(groupBlockSuccess(groupId, accountId)))
      .catch(err => dispatch(groupBlockFail(groupId, accountId, err)));
  };
};

export function groupBlockRequest(groupId, accountId) {
  return {
    type: GROUP_BLOCK_REQUEST,
    groupId,
    accountId,
  };
};

export function groupBlockSuccess(groupId, accountId) {
  return {
    type: GROUP_BLOCK_SUCCESS,
    groupId,
    accountId,
  };
};

export function groupBlockFail(groupId, accountId, error) {
  return {
    type: GROUP_BLOCK_FAIL,
    groupId,
    accountId,
    error,
  };
};
