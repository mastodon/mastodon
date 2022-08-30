import api from '../api';
import { importFetchedGroups } from './importer';

export const GROUP_FETCH_REQUEST = 'GROUP_FETCH_REQUEST';
export const GROUP_FETCH_SUCCESS = 'GROUP_FETCH_SUCCESS';
export const GROUP_FETCH_FAIL    = 'GROUP_FETCH_FAIL';

export const GROUP_RELATIONSHIPS_FETCH_REQUEST = 'GROUP_RELATIONSHIPS_FETCH_REQUEST';
export const GROUP_RELATIONSHIPS_FETCH_SUCCESS = 'GROUP_RELATIONSHIPS_FETCH_SUCCESS';
export const GROUP_RELATIONSHIPS_FETCH_FAIL    = 'GROUP_RELATIONSHIPS_FETCH_FAIL';

export const GROUP_JOIN_REQUEST = 'GROUP_JOIN_REQUEST';
export const GROUP_JOIN_SUCCESS = 'GROUP_JOIN_SUCCESS';
export const GROUP_JOIN_FAIL    = 'GROUP_JOIN_FAIL';

export const GROUP_LEAVE_REQUEST = 'GROUP_LEAVE_REQUEST';
export const GROUP_LEAVE_SUCCESS = 'GROUP_LEAVE_SUCCESS';
export const GROUP_LEAVE_FAIL    = 'GROUP_LEAVE_FAIL';

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
