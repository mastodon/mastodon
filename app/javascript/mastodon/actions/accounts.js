import { browserHistory } from 'mastodon/components/router';
import { debounceWithDispatchAndArguments } from 'mastodon/utils/debounce';

import api, { getLinks } from '../api';

import {
  followAccountSuccess, unfollowAccountSuccess,
  authorizeFollowRequestSuccess, rejectFollowRequestSuccess,
  followAccountRequest, followAccountFail,
  unfollowAccountRequest, unfollowAccountFail,
  muteAccountSuccess, unmuteAccountSuccess,
  blockAccountSuccess, unblockAccountSuccess,
  pinAccountSuccess, unpinAccountSuccess,
  fetchRelationshipsSuccess,
} from './accounts_typed';
import { importFetchedAccount, importFetchedAccounts } from './importer';

export const ACCOUNT_FETCH_REQUEST = 'ACCOUNT_FETCH_REQUEST';
export const ACCOUNT_FETCH_SUCCESS = 'ACCOUNT_FETCH_SUCCESS';
export const ACCOUNT_FETCH_FAIL    = 'ACCOUNT_FETCH_FAIL';

export const ACCOUNT_LOOKUP_REQUEST = 'ACCOUNT_LOOKUP_REQUEST';
export const ACCOUNT_LOOKUP_SUCCESS = 'ACCOUNT_LOOKUP_SUCCESS';
export const ACCOUNT_LOOKUP_FAIL    = 'ACCOUNT_LOOKUP_FAIL';

export const ACCOUNT_BLOCK_REQUEST = 'ACCOUNT_BLOCK_REQUEST';
export const ACCOUNT_BLOCK_FAIL    = 'ACCOUNT_BLOCK_FAIL';

export const ACCOUNT_UNBLOCK_REQUEST = 'ACCOUNT_UNBLOCK_REQUEST';
export const ACCOUNT_UNBLOCK_FAIL    = 'ACCOUNT_UNBLOCK_FAIL';

export const ACCOUNT_MUTE_REQUEST = 'ACCOUNT_MUTE_REQUEST';
export const ACCOUNT_MUTE_FAIL    = 'ACCOUNT_MUTE_FAIL';

export const ACCOUNT_UNMUTE_REQUEST = 'ACCOUNT_UNMUTE_REQUEST';
export const ACCOUNT_UNMUTE_FAIL    = 'ACCOUNT_UNMUTE_FAIL';

export const ACCOUNT_PIN_REQUEST = 'ACCOUNT_PIN_REQUEST';
export const ACCOUNT_PIN_FAIL    = 'ACCOUNT_PIN_FAIL';

export const ACCOUNT_UNPIN_REQUEST = 'ACCOUNT_UNPIN_REQUEST';
export const ACCOUNT_UNPIN_FAIL    = 'ACCOUNT_UNPIN_FAIL';

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
export const RELATIONSHIPS_FETCH_FAIL    = 'RELATIONSHIPS_FETCH_FAIL';

export const FOLLOW_REQUESTS_FETCH_REQUEST = 'FOLLOW_REQUESTS_FETCH_REQUEST';
export const FOLLOW_REQUESTS_FETCH_SUCCESS = 'FOLLOW_REQUESTS_FETCH_SUCCESS';
export const FOLLOW_REQUESTS_FETCH_FAIL    = 'FOLLOW_REQUESTS_FETCH_FAIL';

export const FOLLOW_REQUESTS_EXPAND_REQUEST = 'FOLLOW_REQUESTS_EXPAND_REQUEST';
export const FOLLOW_REQUESTS_EXPAND_SUCCESS = 'FOLLOW_REQUESTS_EXPAND_SUCCESS';
export const FOLLOW_REQUESTS_EXPAND_FAIL    = 'FOLLOW_REQUESTS_EXPAND_FAIL';

export const FOLLOW_REQUEST_AUTHORIZE_REQUEST = 'FOLLOW_REQUEST_AUTHORIZE_REQUEST';
export const FOLLOW_REQUEST_AUTHORIZE_FAIL    = 'FOLLOW_REQUEST_AUTHORIZE_FAIL';

export const FOLLOW_REQUEST_REJECT_REQUEST = 'FOLLOW_REQUEST_REJECT_REQUEST';
export const FOLLOW_REQUEST_REJECT_FAIL    = 'FOLLOW_REQUEST_REJECT_FAIL';

export const ACCOUNT_REVEAL = 'ACCOUNT_REVEAL';

export * from './accounts_typed';

export function fetchAccount(id) {
  return (dispatch) => {
    dispatch(fetchRelationships([id]));
    dispatch(fetchAccountRequest(id));

    api().get(`/api/v1/accounts/${id}`).then(response => {
      dispatch(importFetchedAccount(response.data));
      dispatch(fetchAccountSuccess());
    }).catch(error => {
      dispatch(fetchAccountFail(id, error));
    });
  };
}

export const lookupAccount = acct => (dispatch) => {
  dispatch(lookupAccountRequest(acct));

  api().get('/api/v1/accounts/lookup', { params: { acct } }).then(response => {
    dispatch(fetchRelationships([response.data.id]));
    dispatch(importFetchedAccount(response.data));
    dispatch(lookupAccountSuccess());
  }).catch(error => {
    dispatch(lookupAccountFail(acct, error));
  });
};

export const lookupAccountRequest = (acct) => ({
  type: ACCOUNT_LOOKUP_REQUEST,
  acct,
});

export const lookupAccountSuccess = () => ({
  type: ACCOUNT_LOOKUP_SUCCESS,
});

export const lookupAccountFail = (acct, error) => ({
  type: ACCOUNT_LOOKUP_FAIL,
  acct,
  error,
  skipAlert: true,
});

export function fetchAccountRequest(id) {
  return {
    type: ACCOUNT_FETCH_REQUEST,
    id,
  };
}

export function fetchAccountSuccess() {
  return {
    type: ACCOUNT_FETCH_SUCCESS,
  };
}

export function fetchAccountFail(id, error) {
  return {
    type: ACCOUNT_FETCH_FAIL,
    id,
    error,
    skipAlert: true,
  };
}

export function followAccount(id, options = { reblogs: true }) {
  return (dispatch, getState) => {
    const alreadyFollowing = getState().getIn(['relationships', id, 'following']);
    const locked = getState().getIn(['accounts', id, 'locked'], false);

    dispatch(followAccountRequest({ id, locked }));

    api().post(`/api/v1/accounts/${id}/follow`, options).then(response => {
      dispatch(followAccountSuccess({relationship: response.data, alreadyFollowing}));
    }).catch(error => {
      dispatch(followAccountFail({ id, error, locked }));
    });
  };
}

export function unfollowAccount(id) {
  return (dispatch, getState) => {
    dispatch(unfollowAccountRequest(id));

    api().post(`/api/v1/accounts/${id}/unfollow`).then(response => {
      dispatch(unfollowAccountSuccess({relationship: response.data, statuses: getState().get('statuses')}));
    }).catch(error => {
      dispatch(unfollowAccountFail({ id, error }));
    });
  };
}

export function blockAccount(id) {
  return (dispatch, getState) => {
    dispatch(blockAccountRequest(id));

    api().post(`/api/v1/accounts/${id}/block`).then(response => {
      // Pass in entire statuses map so we can use it to filter stuff in different parts of the reducers
      dispatch(blockAccountSuccess({ relationship: response.data, statuses: getState().get('statuses') }));
    }).catch(error => {
      dispatch(blockAccountFail({ id, error }));
    });
  };
}

export function unblockAccount(id) {
  return (dispatch) => {
    dispatch(unblockAccountRequest(id));

    api().post(`/api/v1/accounts/${id}/unblock`).then(response => {
      dispatch(unblockAccountSuccess({ relationship: response.data }));
    }).catch(error => {
      dispatch(unblockAccountFail({ id, error }));
    });
  };
}

export function blockAccountRequest(id) {
  return {
    type: ACCOUNT_BLOCK_REQUEST,
    id,
  };
}
export function blockAccountFail(error) {
  return {
    type: ACCOUNT_BLOCK_FAIL,
    error,
  };
}

export function unblockAccountRequest(id) {
  return {
    type: ACCOUNT_UNBLOCK_REQUEST,
    id,
  };
}

export function unblockAccountFail(error) {
  return {
    type: ACCOUNT_UNBLOCK_FAIL,
    error,
  };
}


export function muteAccount(id, notifications, duration=0) {
  return (dispatch, getState) => {
    dispatch(muteAccountRequest(id));

    api().post(`/api/v1/accounts/${id}/mute`, { notifications, duration }).then(response => {
      // Pass in entire statuses map so we can use it to filter stuff in different parts of the reducers
      dispatch(muteAccountSuccess({ relationship: response.data, statuses: getState().get('statuses') }));
    }).catch(error => {
      dispatch(muteAccountFail({ id, error }));
    });
  };
}

export function unmuteAccount(id) {
  return (dispatch) => {
    dispatch(unmuteAccountRequest(id));

    api().post(`/api/v1/accounts/${id}/unmute`).then(response => {
      dispatch(unmuteAccountSuccess({ relationship: response.data }));
    }).catch(error => {
      dispatch(unmuteAccountFail({ id, error }));
    });
  };
}

export function muteAccountRequest(id) {
  return {
    type: ACCOUNT_MUTE_REQUEST,
    id,
  };
}

export function muteAccountFail(error) {
  return {
    type: ACCOUNT_MUTE_FAIL,
    error,
  };
}

export function unmuteAccountRequest(id) {
  return {
    type: ACCOUNT_UNMUTE_REQUEST,
    id,
  };
}

export function unmuteAccountFail(error) {
  return {
    type: ACCOUNT_UNMUTE_FAIL,
    error,
  };
}


export function fetchFollowers(id) {
  return (dispatch) => {
    dispatch(fetchFollowersRequest(id));

    api().get(`/api/v1/accounts/${id}/followers`).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(importFetchedAccounts(response.data));
      dispatch(fetchFollowersSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(fetchFollowersFail(id, error));
    });
  };
}

export function fetchFollowersRequest(id) {
  return {
    type: FOLLOWERS_FETCH_REQUEST,
    id,
  };
}

export function fetchFollowersSuccess(id, accounts, next) {
  return {
    type: FOLLOWERS_FETCH_SUCCESS,
    id,
    accounts,
    next,
  };
}

export function fetchFollowersFail(id, error) {
  return {
    type: FOLLOWERS_FETCH_FAIL,
    id,
    error,
    skipNotFound: true,
  };
}

export function expandFollowers(id) {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'followers', id, 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowersRequest(id));

    api().get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(importFetchedAccounts(response.data));
      dispatch(expandFollowersSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(expandFollowersFail(id, error));
    });
  };
}

export function expandFollowersRequest(id) {
  return {
    type: FOLLOWERS_EXPAND_REQUEST,
    id,
  };
}

export function expandFollowersSuccess(id, accounts, next) {
  return {
    type: FOLLOWERS_EXPAND_SUCCESS,
    id,
    accounts,
    next,
  };
}

export function expandFollowersFail(id, error) {
  return {
    type: FOLLOWERS_EXPAND_FAIL,
    id,
    error,
  };
}

export function fetchFollowing(id) {
  return (dispatch) => {
    dispatch(fetchFollowingRequest(id));

    api().get(`/api/v1/accounts/${id}/following`).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(importFetchedAccounts(response.data));
      dispatch(fetchFollowingSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(fetchFollowingFail(id, error));
    });
  };
}

export function fetchFollowingRequest(id) {
  return {
    type: FOLLOWING_FETCH_REQUEST,
    id,
  };
}

export function fetchFollowingSuccess(id, accounts, next) {
  return {
    type: FOLLOWING_FETCH_SUCCESS,
    id,
    accounts,
    next,
  };
}

export function fetchFollowingFail(id, error) {
  return {
    type: FOLLOWING_FETCH_FAIL,
    id,
    error,
    skipNotFound: true,
  };
}

export function expandFollowing(id) {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'following', id, 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowingRequest(id));

    api().get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');

      dispatch(importFetchedAccounts(response.data));
      dispatch(expandFollowingSuccess(id, response.data, next ? next.uri : null));
      dispatch(fetchRelationships(response.data.map(item => item.id)));
    }).catch(error => {
      dispatch(expandFollowingFail(id, error));
    });
  };
}

export function expandFollowingRequest(id) {
  return {
    type: FOLLOWING_EXPAND_REQUEST,
    id,
  };
}

export function expandFollowingSuccess(id, accounts, next) {
  return {
    type: FOLLOWING_EXPAND_SUCCESS,
    id,
    accounts,
    next,
  };
}

export function expandFollowingFail(id, error) {
  return {
    type: FOLLOWING_EXPAND_FAIL,
    id,
    error,
  };
}

const debouncedFetchRelationships = debounceWithDispatchAndArguments((dispatch, ...newAccountIds) => {
  if (newAccountIds.length === 0) {
    return;
  }

  dispatch(fetchRelationshipsRequest(newAccountIds));

  api().get(`/api/v1/accounts/relationships?with_suspended=true&${newAccountIds.map(id => `id[]=${id}`).join('&')}`).then(response => {
    dispatch(fetchRelationshipsSuccess({ relationships: response.data }));
  }).catch(error => {
    dispatch(fetchRelationshipsFail(error));
  });
}, { delay: 500 });

export function fetchRelationships(accountIds) {
  return (dispatch, getState) => {
    const state = getState();
    const loadedRelationships = state.get('relationships');
    const newAccountIds = accountIds.filter(id => loadedRelationships.get(id, null) === null);
    const signedIn = !!state.getIn(['meta', 'me']);

    if (!signedIn || newAccountIds.length === 0) {
      return;
    }

    debouncedFetchRelationships(dispatch, ...newAccountIds);
  };
}

export function fetchRelationshipsRequest(ids) {
  return {
    type: RELATIONSHIPS_FETCH_REQUEST,
    ids,
    skipLoading: true,
  };
}

export function fetchRelationshipsFail(error) {
  return {
    type: RELATIONSHIPS_FETCH_FAIL,
    error,
    skipLoading: true,
    skipNotFound: true,
  };
}

export function fetchFollowRequests() {
  return (dispatch) => {
    dispatch(fetchFollowRequestsRequest());

    api().get('/api/v1/follow_requests').then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedAccounts(response.data));
      dispatch(fetchFollowRequestsSuccess(response.data, next ? next.uri : null));
    }).catch(error => dispatch(fetchFollowRequestsFail(error)));
  };
}

export function fetchFollowRequestsRequest() {
  return {
    type: FOLLOW_REQUESTS_FETCH_REQUEST,
  };
}

export function fetchFollowRequestsSuccess(accounts, next) {
  return {
    type: FOLLOW_REQUESTS_FETCH_SUCCESS,
    accounts,
    next,
  };
}

export function fetchFollowRequestsFail(error) {
  return {
    type: FOLLOW_REQUESTS_FETCH_FAIL,
    error,
  };
}

export function expandFollowRequests() {
  return (dispatch, getState) => {
    const url = getState().getIn(['user_lists', 'follow_requests', 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowRequestsRequest());

    api().get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedAccounts(response.data));
      dispatch(expandFollowRequestsSuccess(response.data, next ? next.uri : null));
    }).catch(error => dispatch(expandFollowRequestsFail(error)));
  };
}

export function expandFollowRequestsRequest() {
  return {
    type: FOLLOW_REQUESTS_EXPAND_REQUEST,
  };
}

export function expandFollowRequestsSuccess(accounts, next) {
  return {
    type: FOLLOW_REQUESTS_EXPAND_SUCCESS,
    accounts,
    next,
  };
}

export function expandFollowRequestsFail(error) {
  return {
    type: FOLLOW_REQUESTS_EXPAND_FAIL,
    error,
  };
}

export function authorizeFollowRequest(id) {
  return (dispatch) => {
    dispatch(authorizeFollowRequestRequest(id));

    api()
      .post(`/api/v1/follow_requests/${id}/authorize`)
      .then(() => dispatch(authorizeFollowRequestSuccess({ id })))
      .catch(error => dispatch(authorizeFollowRequestFail(id, error)));
  };
}

export function authorizeFollowRequestRequest(id) {
  return {
    type: FOLLOW_REQUEST_AUTHORIZE_REQUEST,
    id,
  };
}

export function authorizeFollowRequestFail(id, error) {
  return {
    type: FOLLOW_REQUEST_AUTHORIZE_FAIL,
    id,
    error,
  };
}


export function rejectFollowRequest(id) {
  return (dispatch) => {
    dispatch(rejectFollowRequestRequest(id));

    api()
      .post(`/api/v1/follow_requests/${id}/reject`)
      .then(() => dispatch(rejectFollowRequestSuccess({ id })))
      .catch(error => dispatch(rejectFollowRequestFail(id, error)));
  };
}

export function rejectFollowRequestRequest(id) {
  return {
    type: FOLLOW_REQUEST_REJECT_REQUEST,
    id,
  };
}

export function rejectFollowRequestFail(id, error) {
  return {
    type: FOLLOW_REQUEST_REJECT_FAIL,
    id,
    error,
  };
}

export function pinAccount(id) {
  return (dispatch) => {
    dispatch(pinAccountRequest(id));

    api().post(`/api/v1/accounts/${id}/pin`).then(response => {
      dispatch(pinAccountSuccess({ relationship: response.data }));
    }).catch(error => {
      dispatch(pinAccountFail(error));
    });
  };
}

export function unpinAccount(id) {
  return (dispatch) => {
    dispatch(unpinAccountRequest(id));

    api().post(`/api/v1/accounts/${id}/unpin`).then(response => {
      dispatch(unpinAccountSuccess({ relationship: response.data }));
    }).catch(error => {
      dispatch(unpinAccountFail(error));
    });
  };
}

export function pinAccountRequest(id) {
  return {
    type: ACCOUNT_PIN_REQUEST,
    id,
  };
}

export function pinAccountFail(error) {
  return {
    type: ACCOUNT_PIN_FAIL,
    error,
  };
}

export function unpinAccountRequest(id) {
  return {
    type: ACCOUNT_UNPIN_REQUEST,
    id,
  };
}

export function unpinAccountFail(error) {
  return {
    type: ACCOUNT_UNPIN_FAIL,
    error,
  };
}

export const updateAccount = ({ displayName, note, avatar, header, discoverable, indexable }) => (dispatch) => {
  const data = new FormData();

  data.append('display_name', displayName);
  data.append('note', note);
  if (avatar) data.append('avatar', avatar);
  if (header) data.append('header', header);
  data.append('discoverable', discoverable);
  data.append('indexable', indexable);

  return api().patch('/api/v1/accounts/update_credentials', data).then(response => {
    dispatch(importFetchedAccount(response.data));
  });
};

export const navigateToProfile = (accountId) => {
  return (_dispatch, getState) => {
    const acct = getState().accounts.getIn([accountId, 'acct']);

    if (acct) {
      browserHistory.push(`/@${acct}`);
    }
  };
};
