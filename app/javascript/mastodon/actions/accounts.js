import api, { getLinks } from '../api';
import Immutable from 'immutable';

export const ACCOUNT_FETCH_REQUEST = 'ACCOUNT_FETCH_REQUEST';
export const ACCOUNT_FETCH_SUCCESS = 'ACCOUNT_FETCH_SUCCESS';
export const ACCOUNT_FETCH_FAIL    = 'ACCOUNT_FETCH_FAIL';

export const ACCOUNT_FOLLOW_REQUEST = 'ACCOUNT_FOLLOW_REQUEST';
export const ACCOUNT_FOLLOW_SUCCESS = 'ACCOUNT_FOLLOW_SUCCESS';
export const ACCOUNT_FOLLOW_FAIL    = 'ACCOUNT_FOLLOW_FAIL';

export const ACCOUNT_UNFOLLOW_REQUEST = 'ACCOUNT_UNFOLLOW_REQUEST';
export const ACCOUNT_UNFOLLOW_SUCCESS = 'ACCOUNT_UNFOLLOW_SUCCESS';
export const ACCOUNT_UNFOLLOW_FAIL    = 'ACCOUNT_UNFOLLOW_FAIL';

export const ACCOUNT_BLOCK_REQUEST = 'ACCOUNT_BLOCK_REQUEST';
export const ACCOUNT_BLOCK_SUCCESS = 'ACCOUNT_BLOCK_SUCCESS';
export const ACCOUNT_BLOCK_FAIL    = 'ACCOUNT_BLOCK_FAIL';

export const ACCOUNT_UNBLOCK_REQUEST = 'ACCOUNT_UNBLOCK_REQUEST';
export const ACCOUNT_UNBLOCK_SUCCESS = 'ACCOUNT_UNBLOCK_SUCCESS';
export const ACCOUNT_UNBLOCK_FAIL    = 'ACCOUNT_UNBLOCK_FAIL';

export const ACCOUNT_MUTE_REQUEST = 'ACCOUNT_MUTE_REQUEST';
export const ACCOUNT_MUTE_SUCCESS = 'ACCOUNT_MUTE_SUCCESS';
export const ACCOUNT_MUTE_FAIL    = 'ACCOUNT_MUTE_FAIL';

export const ACCOUNT_UNMUTE_REQUEST = 'ACCOUNT_UNMUTE_REQUEST';
export const ACCOUNT_UNMUTE_SUCCESS = 'ACCOUNT_UNMUTE_SUCCESS';
export const ACCOUNT_UNMUTE_FAIL    = 'ACCOUNT_UNMUTE_FAIL';

export const ACCOUNT_TIMELINE_FETCH_REQUEST = 'ACCOUNT_TIMELINE_FETCH_REQUEST';
export const ACCOUNT_TIMELINE_FETCH_SUCCESS = 'ACCOUNT_TIMELINE_FETCH_SUCCESS';
export const ACCOUNT_TIMELINE_FETCH_FAIL    = 'ACCOUNT_TIMELINE_FETCH_FAIL';

export const ACCOUNT_TIMELINE_EXPAND_REQUEST = 'ACCOUNT_TIMELINE_EXPAND_REQUEST';
export const ACCOUNT_TIMELINE_EXPAND_SUCCESS = 'ACCOUNT_TIMELINE_EXPAND_SUCCESS';
export const ACCOUNT_TIMELINE_EXPAND_FAIL    = 'ACCOUNT_TIMELINE_EXPAND_FAIL';

export const ACCOUNT_MEDIA_TIMELINE_FETCH_REQUEST = 'ACCOUNT_MEDIA_TIMELINE_FETCH_REQUEST';
export const ACCOUNT_MEDIA_TIMELINE_FETCH_SUCCESS = 'ACCOUNT_MEDIA_TIMELINE_FETCH_SUCCESS';
export const ACCOUNT_MEDIA_TIMELINE_FETCH_FAIL    = 'ACCOUNT_MEDIA_TIMELINE_FETCH_FAIL';

export const ACCOUNT_MEDIA_TIMELINE_EXPAND_REQUEST = 'ACCOUNT_MEDIA_TIMELINE_EXPAND_REQUEST';
export const ACCOUNT_MEDIA_TIMELINE_EXPAND_SUCCESS = 'ACCOUNT_MEDIA_TIMELINE_EXPAND_SUCCESS';
export const ACCOUNT_MEDIA_TIMELINE_EXPAND_FAIL    = 'ACCOUNT_MEDIA_TIMELINE_EXPAND_FAIL';

export const FOLLOWERS_FETCH_REQUEST = 'FOLLOWERS_FETCH_REQUEST';
export const FOLLOWERS_FETCH_SUCCESS = 'FOLLOWERS_FETCH_SUCCESS';
export const FOLLOWERS_FETCH_FAIL    = 'FOLLOWERS_FETCH_FAIL';

export const FOLLOWERS_EXPAND_REQUEST = 'FOLLOWERS_EXPAND_REQUEST';
export const FOLLOWERS_EXPAND_SUCCESS = 'FOLLOWERS_EXPAND_SUCCESS';
export const FOLLOWERS_EXPAND_FAIL    = 'FOLLOWERS_EXPAND_FAIL';

export const FOLLOWING_FETCH_REQUEST = 'FOLLOWING_FETCH_REQUEST';
export const FOLLOWING_FETCH_SUCCESS = 'FOLLOWING_FETCH_SUCCESS';
export const FOLLOWING_FETCH_FAIL    = 'FOLLOWING_FETCH_FAIL';

export const FOLLOWING_EXPAND_REQUEST = 'FOLLOWING_EXPAND_REQUEST';
export const FOLLOWING_EXPAND_SUCCESS = 'FOLLOWING_EXPAND_SUCCESS';
export const FOLLOWING_EXPAND_FAIL    = 'FOLLOWING_EXPAND_FAIL';

export const RELATIONSHIPS_FETCH_REQUEST = 'RELATIONSHIPS_FETCH_REQUEST';
export const RELATIONSHIPS_FETCH_SUCCESS = 'RELATIONSHIPS_FETCH_SUCCESS';
export const RELATIONSHIPS_FETCH_FAIL    = 'RELATIONSHIPS_FETCH_FAIL';

export const FOLLOW_REQUESTS_FETCH_REQUEST = 'FOLLOW_REQUESTS_FETCH_REQUEST';
export const FOLLOW_REQUESTS_FETCH_SUCCESS = 'FOLLOW_REQUESTS_FETCH_SUCCESS';
export const FOLLOW_REQUESTS_FETCH_FAIL    = 'FOLLOW_REQUESTS_FETCH_FAIL';

export const FOLLOW_REQUESTS_EXPAND_REQUEST = 'FOLLOW_REQUESTS_EXPAND_REQUEST';
export const FOLLOW_REQUESTS_EXPAND_SUCCESS = 'FOLLOW_REQUESTS_EXPAND_SUCCESS';
export const FOLLOW_REQUESTS_EXPAND_FAIL    = 'FOLLOW_REQUESTS_EXPAND_FAIL';

export const FOLLOW_REQUEST_AUTHORIZE_REQUEST = 'FOLLOW_REQUEST_AUTHORIZE_REQUEST';
export const FOLLOW_REQUEST_AUTHORIZE_SUCCESS = 'FOLLOW_REQUEST_AUTHORIZE_SUCCESS';
export const FOLLOW_REQUEST_AUTHORIZE_FAIL    = 'FOLLOW_REQUEST_AUTHORIZE_FAIL';

export const FOLLOW_REQUEST_REJECT_REQUEST = 'FOLLOW_REQUEST_REJECT_REQUEST';
export const FOLLOW_REQUEST_REJECT_SUCCESS = 'FOLLOW_REQUEST_REJECT_SUCCESS';
export const FOLLOW_REQUEST_REJECT_FAIL    = 'FOLLOW_REQUEST_REJECT_FAIL';

export function fetchAccount(id) {
  return (dispatch, getState) => {
    dispatch(fetchRelationships([id]));

    if (getState().getIn(['accounts', id], null) !== null) {
      return;
    }

    dispatch(fetchAccountRequest(id));

    api(getState).get(`/api/v1/accounts/${id}`).then(response => {
      dispatch(fetchAccountSuccess(response.data));
    }).catch(error => {
      dispatch(fetchAccountFail(id, error));
    });
  };
};

export function fetchAccountTimeline(id, replace = false) {
  return (dispatch, getState) => {
    const ids      = getState().getIn(['timelines', 'accounts_timelines', id, 'items'], Immutable.List());
    const newestId = ids.size > 0 ? ids.first() : null;

    let params = {};
    let skipLoading = false;

    if (newestId !== null && !replace) {
      params.since_id = newestId;
      skipLoading = true;
    }

    dispatch(fetchAccountTimelineRequest(id, skipLoading));

    api(getState).get(`/api/v1/accounts/${id}/statuses`, { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(fetchAccountTimelineSuccess(id, response.data, replace, skipLoading, next));
    }).catch(error => {
      dispatch(fetchAccountTimelineFail(id, error, skipLoading));
    });
  };
};

export function fetchAccountMediaTimeline(id, replace = false) {
  return (dispatch, getState) => {
    const ids      = getState().getIn(['timelines', 'accounts_media_timelines', id, 'items'], Immutable.List());
    const newestId = ids.size > 0 ? ids.first() : null;

    let params = { only_media: 'true', limit: 12 };
    let skipLoading = false;

    if (newestId !== null && !replace) {
      params.since_id = newestId;
      skipLoading = true;
    }

    dispatch(fetchAccountMediaTimelineRequest(id, skipLoading));

    api(getState).get(`/api/v1/accounts/${id}/statuses`, { params }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(fetchAccountMediaTimelineSuccess(id, response.data, replace, skipLoading, next));
    }).catch(error => {
      dispatch(fetchAccountMediaTimelineFail(id, error, skipLoading));
    });
  };
};

export function expandAccountTimeline(id) {
  return (dispatch, getState) => {
    const lastId = getState().getIn(['timelines', 'accounts_timelines', id, 'items'], Immutable.List()).last();

    dispatch(expandAccountTimelineRequest(id));

    api(getState).get(`/api/v1/accounts/${id}/statuses`, {
      params: {
        limit: 10,
        max_id: lastId,
      },
    }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandAccountTimelineSuccess(id, response.data, next));
    }).catch(error => {
      dispatch(expandAccountTimelineFail(id, error));
    });
  };
};

export function expandAccountMediaTimeline(id) {
  return (dispatch, getState) => {
    const lastId = getState().getIn(['timelines', 'accounts_media_timelines', id, 'items'], Immutable.List()).last();

    dispatch(expandAccountMediaTimelineRequest(id));

    api(getState).get(`/api/v1/accounts/${id}/statuses`, {
      params: {
        limit: 12,
        only_media: 'true',
        max_id: lastId,
      },
    }).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandAccountMediaTimelineSuccess(id, response.data, next));
    }).catch(error => {
      dispatch(expandAccountMediaTimelineFail(id, error));
    });
  };
};

export function fetchAccountRequest(id) {
  return {
    type: ACCOUNT_FETCH_REQUEST,
    id,
  };
};

export function fetchAccountSuccess(account) {
  return {
    type: ACCOUNT_FETCH_SUCCESS,
    account,
  };
};

export function fetchAccountFail(id, error) {
  return {
    type: ACCOUNT_FETCH_FAIL,
    id,
    error,
    skipAlert: true,
  };
};

export function followAccount(id) {
  return (dispatch, getState) => {
    dispatch(followAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/follow`).then(response => {
      dispatch(followAccountSuccess(response.data));
    }).catch(error => {
      dispatch(followAccountFail(error));
    });
  };
};

export function unfollowAccount(id) {
  return (dispatch, getState) => {
    dispatch(unfollowAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/unfollow`).then(response => {
      dispatch(unfollowAccountSuccess(response.data));
    }).catch(error => {
      dispatch(unfollowAccountFail(error));
    });
  };
};

export function followAccountRequest(id) {
  return {
    type: ACCOUNT_FOLLOW_REQUEST,
    id,
  };
};

export function followAccountSuccess(relationship) {
  return {
    type: ACCOUNT_FOLLOW_SUCCESS,
    relationship,
  };
};

export function followAccountFail(error) {
  return {
    type: ACCOUNT_FOLLOW_FAIL,
    error,
  };
};

export function unfollowAccountRequest(id) {
  return {
    type: ACCOUNT_UNFOLLOW_REQUEST,
    id,
  };
};

export function unfollowAccountSuccess(relationship) {
  return {
    type: ACCOUNT_UNFOLLOW_SUCCESS,
    relationship,
  };
};

export function unfollowAccountFail(error) {
  return {
    type: ACCOUNT_UNFOLLOW_FAIL,
    error,
  };
};

export function fetchAccountTimelineRequest(id, skipLoading) {
  return {
    type: ACCOUNT_TIMELINE_FETCH_REQUEST,
    id,
    skipLoading,
  };
};

export function fetchAccountTimelineSuccess(id, statuses, replace, skipLoading, next) {
  return {
    type: ACCOUNT_TIMELINE_FETCH_SUCCESS,
    id,
    statuses,
    replace,
    skipLoading,
    next,
  };
};

export function fetchAccountTimelineFail(id, error, skipLoading) {
  return {
    type: ACCOUNT_TIMELINE_FETCH_FAIL,
    id,
    error,
    skipLoading,
    skipAlert: error.response.status === 404,
  };
};

export function fetchAccountMediaTimelineRequest(id, skipLoading) {
  return {
    type: ACCOUNT_MEDIA_TIMELINE_FETCH_REQUEST,
    id,
    skipLoading,
  };
};

export function fetchAccountMediaTimelineSuccess(id, statuses, replace, skipLoading, next) {
  return {
    type: ACCOUNT_MEDIA_TIMELINE_FETCH_SUCCESS,
    id,
    statuses,
    replace,
    skipLoading,
    next,
  };
};

export function fetchAccountMediaTimelineFail(id, error, skipLoading) {
  return {
    type: ACCOUNT_MEDIA_TIMELINE_FETCH_FAIL,
    id,
    error,
    skipLoading,
    skipAlert: error.response.status === 404,
  };
};

export function expandAccountTimelineRequest(id) {
  return {
    type: ACCOUNT_TIMELINE_EXPAND_REQUEST,
    id,
  };
};

export function expandAccountTimelineSuccess(id, statuses, next) {
  return {
    type: ACCOUNT_TIMELINE_EXPAND_SUCCESS,
    id,
    statuses,
    next,
  };
};

export function expandAccountTimelineFail(id, error) {
  return {
    type: ACCOUNT_TIMELINE_EXPAND_FAIL,
    id,
    error,
  };
};

export function expandAccountMediaTimelineRequest(id) {
  return {
    type: ACCOUNT_MEDIA_TIMELINE_EXPAND_REQUEST,
    id,
  };
};

export function expandAccountMediaTimelineSuccess(id, statuses, next) {
  return {
    type: ACCOUNT_MEDIA_TIMELINE_EXPAND_SUCCESS,
    id,
    statuses,
    next,
  };
};

export function expandAccountMediaTimelineFail(id, error) {
  return {
    type: ACCOUNT_MEDIA_TIMELINE_EXPAND_FAIL,
    id,
    error,
  };
};

export function blockAccount(id) {
  return (dispatch, getState) => {
    dispatch(blockAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/block`).then(response => {
      // Pass in entire statuses map so we can use it to filter stuff in different parts of the reducers
      dispatch(blockAccountSuccess(response.data, getState().get('statuses')));
    }).catch(error => {
      dispatch(blockAccountFail(id, error));
    });
  };
};

export function unblockAccount(id) {
  return (dispatch, getState) => {
    dispatch(unblockAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/unblock`).then(response => {
      dispatch(unblockAccountSuccess(response.data));
    }).catch(error => {
      dispatch(unblockAccountFail(id, error));
    });
  };
};

export function blockAccountRequest(id) {
  return {
    type: ACCOUNT_BLOCK_REQUEST,
    id,
  };
};

export function blockAccountSuccess(relationship, statuses) {
  return {
    type: ACCOUNT_BLOCK_SUCCESS,
    relationship,
    statuses,
  };
};

export function blockAccountFail(error) {
  return {
    type: ACCOUNT_BLOCK_FAIL,
    error,
  };
};

export function unblockAccountRequest(id) {
  return {
    type: ACCOUNT_UNBLOCK_REQUEST,
    id,
  };
};

export function unblockAccountSuccess(relationship) {
  return {
    type: ACCOUNT_UNBLOCK_SUCCESS,
    relationship,
  };
};

export function unblockAccountFail(error) {
  return {
    type: ACCOUNT_UNBLOCK_FAIL,
    error,
  };
};


export function muteAccount(id) {
  return (dispatch, getState) => {
    dispatch(muteAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/mute`).then(response => {
      // Pass in entire statuses map so we can use it to filter stuff in different parts of the reducers
      dispatch(muteAccountSuccess(response.data, getState().get('statuses')));
    }).catch(error => {
      dispatch(muteAccountFail(id, error));
    });
  };
};

export function unmuteAccount(id) {
  return (dispatch, getState) => {
    dispatch(unmuteAccountRequest(id));

    api(getState).post(`/api/v1/accounts/${id}/unmute`).then(response => {
      dispatch(unmuteAccountSuccess(response.data));
    }).catch(error => {
      dispatch(unmuteAccountFail(id, error));
    });
  };
};

export function muteAccountRequest(id) {
  return {
    type: ACCOUNT_MUTE_REQUEST,
    id,
  };
};

export function muteAccountSuccess(relationship, statuses) {
  return {
    type: ACCOUNT_MUTE_SUCCESS,
    relationship,
    statuses,
  };
};

export function muteAccountFail(error) {
  return {
    type: ACCOUNT_MUTE_FAIL,
    error,
  };
};

export function unmuteAccountRequest(id) {
  return {
    type: ACCOUNT_UNMUTE_REQUEST,
    id,
  };
};

export function unmuteAccountSuccess(relationship) {
  return {
    type: ACCOUNT_UNMUTE_SUCCESS,
    relationship,
  };
};

export function unmuteAccountFail(error) {
  return {
    type: ACCOUNT_UNMUTE_FAIL,
    error,
  };
};


export function fetchFollowers(id) {
  return (dispatch, getState) => {
    dispatch(fetchFollowersRequest(id));

    api(getState).get(`/api/v1/accounts/${id}/followers`).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(fetchFollowersSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(fetchFollowersFail(id, error));
    });
  };
};

export function fetchFollowersRequest(id) {
  return {
    type: FOLLOWERS_FETCH_REQUEST,
    id,
  };
};

export function fetchFollowersSuccess(id, accounts, next) {
  return {
    type: FOLLOWERS_FETCH_SUCCESS,
    id,
    accounts,
    next,
  };
};

export function fetchFollowersFail(id, error) {
  return {
    type: FOLLOWERS_FETCH_FAIL,
    id,
    error,
  };
};

export function expandFollowers(id) {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'followers', id, 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowersRequest(id));

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(expandFollowersSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(expandFollowersFail(id, error));
    });
  };
};

export function expandFollowersRequest(id) {
  return {
    type: FOLLOWERS_EXPAND_REQUEST,
    id,
  };
};

export function expandFollowersSuccess(id, accounts, next) {
  return {
    type: FOLLOWERS_EXPAND_SUCCESS,
    id,
    accounts,
    next,
  };
};

export function expandFollowersFail(id, error) {
  return {
    type: FOLLOWERS_EXPAND_FAIL,
    id,
    error,
  };
};

export function fetchFollowing(id) {
  return (dispatch, getState) => {
    dispatch(fetchFollowingRequest(id));

    api(getState).get(`/api/v1/accounts/${id}/following`).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(fetchFollowingSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(fetchFollowingFail(id, error));
    });
  };
};

export function fetchFollowingRequest(id) {
  return {
    type: FOLLOWING_FETCH_REQUEST,
    id,
  };
};

export function fetchFollowingSuccess(id, accounts, next) {
  return {
    type: FOLLOWING_FETCH_SUCCESS,
    id,
    accounts,
    next,
  };
};

export function fetchFollowingFail(id, error) {
  return {
    type: FOLLOWING_FETCH_FAIL,
    id,
    error,
  };
};

export function expandFollowing(id) {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'following', id, 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowingRequest(id));

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(expandFollowingSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(expandFollowingFail(id, error));
    });
  };
};

export function expandFollowingRequest(id) {
  return {
    type: FOLLOWING_EXPAND_REQUEST,
    id,
  };
};

export function expandFollowingSuccess(id, accounts, next) {
  return {
    type: FOLLOWING_EXPAND_SUCCESS,
    id,
    accounts,
    next,
  };
};

export function expandFollowingFail(id, error) {
  return {
    type: FOLLOWING_EXPAND_FAIL,
    id,
    error,
  };
};

export function fetchRelationships(accountIds) {
  return (dispatch, getState) => {
    const loadedRelationships = getState().get('relationships');
    const newAccountIds = accountIds.filter(id => loadedRelationships.get(id, null) === null);

    if (newAccountIds.length === 0) {
      return;
    }

    dispatch(fetchRelationshipsRequest(newAccountIds));

    api(getState).get(`/api/v1/accounts/relationships?${newAccountIds.map(id => `id[]=${id}`).join('&')}`).then(response => {
      dispatch(fetchRelationshipsSuccess(response.data));
    }).catch(error => {
      dispatch(fetchRelationshipsFail(error));
    });
  };
};

export function fetchRelationshipsRequest(ids) {
  return {
    type: RELATIONSHIPS_FETCH_REQUEST,
    ids,
    skipLoading: true,
  };
};

export function fetchRelationshipsSuccess(relationships) {
  return {
    type: RELATIONSHIPS_FETCH_SUCCESS,
    relationships,
    skipLoading: true,
  };
};

export function fetchRelationshipsFail(error) {
  return {
    type: RELATIONSHIPS_FETCH_FAIL,
    error,
    skipLoading: true,
  };
};

export function fetchFollowRequests() {
  return (dispatch, getState) => {
    dispatch(fetchFollowRequestsRequest());

    api(getState).get('/api/v1/follow_requests').then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(fetchFollowRequestsSuccess(response.data, next ? next.uri : null));
    }).catch(error => dispatch(fetchFollowRequestsFail(error)));
  };
};

export function fetchFollowRequestsRequest() {
  return {
    type: FOLLOW_REQUESTS_FETCH_REQUEST,
  };
};

export function fetchFollowRequestsSuccess(accounts, next) {
  return {
    type: FOLLOW_REQUESTS_FETCH_SUCCESS,
    accounts,
    next,
  };
};

export function fetchFollowRequestsFail(error) {
  return {
    type: FOLLOW_REQUESTS_FETCH_FAIL,
    error,
  };
};

export function expandFollowRequests() {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'follow_requests', 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowRequestsRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandFollowRequestsSuccess(response.data, next ? next.uri : null));
    }).catch(error => dispatch(expandFollowRequestsFail(error)));
  };
};

export function expandFollowRequestsRequest() {
  return {
    type: FOLLOW_REQUESTS_EXPAND_REQUEST,
  };
};

export function expandFollowRequestsSuccess(accounts, next) {
  return {
    type: FOLLOW_REQUESTS_EXPAND_SUCCESS,
    accounts,
    next,
  };
};

export function expandFollowRequestsFail(error) {
  return {
    type: FOLLOW_REQUESTS_EXPAND_FAIL,
    error,
  };
};

export function authorizeFollowRequest(id) {
  return (dispatch, getState) => {
    dispatch(authorizeFollowRequestRequest(id));

    api(getState)
      .post(`/api/v1/follow_requests/${id}/authorize`)
      .then(response => dispatch(authorizeFollowRequestSuccess(id)))
      .catch(error => dispatch(authorizeFollowRequestFail(id, error)));
  };
};

export function authorizeFollowRequestRequest(id) {
  return {
    type: FOLLOW_REQUEST_AUTHORIZE_REQUEST,
    id,
  };
};

export function authorizeFollowRequestSuccess(id) {
  return {
    type: FOLLOW_REQUEST_AUTHORIZE_SUCCESS,
    id,
  };
};

export function authorizeFollowRequestFail(id, error) {
  return {
    type: FOLLOW_REQUEST_AUTHORIZE_FAIL,
    id,
    error,
  };
};


export function rejectFollowRequest(id) {
  return (dispatch, getState) => {
    dispatch(rejectFollowRequestRequest(id));

    api(getState)
      .post(`/api/v1/follow_requests/${id}/reject`)
      .then(response => dispatch(rejectFollowRequestSuccess(id)))
      .catch(error => dispatch(rejectFollowRequestFail(id, error)));
  };
};

export function rejectFollowRequestRequest(id) {
  return {
    type: FOLLOW_REQUEST_REJECT_REQUEST,
    id,
  };
};

export function rejectFollowRequestSuccess(id) {
  return {
    type: FOLLOW_REQUEST_REJECT_SUCCESS,
    id,
  };
};

export function rejectFollowRequestFail(id, error) {
  return {
    type: FOLLOW_REQUEST_REJECT_FAIL,
    id,
    error,
  };
};
