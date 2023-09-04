import api, { getLinks } from '../api';

export const HASHTAG_FETCH_REQUEST = 'HASHTAG_FETCH_REQUEST';
export const HASHTAG_FETCH_SUCCESS = 'HASHTAG_FETCH_SUCCESS';
export const HASHTAG_FETCH_FAIL    = 'HASHTAG_FETCH_FAIL';

export const FOLLOWED_HASHTAGS_FETCH_REQUEST = 'FOLLOWED_HASHTAGS_FETCH_REQUEST';
export const FOLLOWED_HASHTAGS_FETCH_SUCCESS = 'FOLLOWED_HASHTAGS_FETCH_SUCCESS';
export const FOLLOWED_HASHTAGS_FETCH_FAIL    = 'FOLLOWED_HASHTAGS_FETCH_FAIL';

export const FOLLOWED_HASHTAGS_EXPAND_REQUEST = 'FOLLOWED_HASHTAGS_EXPAND_REQUEST';
export const FOLLOWED_HASHTAGS_EXPAND_SUCCESS = 'FOLLOWED_HASHTAGS_EXPAND_SUCCESS';
export const FOLLOWED_HASHTAGS_EXPAND_FAIL    = 'FOLLOWED_HASHTAGS_EXPAND_FAIL';

export const HASHTAG_FOLLOW_REQUEST = 'HASHTAG_FOLLOW_REQUEST';
export const HASHTAG_FOLLOW_SUCCESS = 'HASHTAG_FOLLOW_SUCCESS';
export const HASHTAG_FOLLOW_FAIL    = 'HASHTAG_FOLLOW_FAIL';

export const HASHTAG_UNFOLLOW_REQUEST = 'HASHTAG_UNFOLLOW_REQUEST';
export const HASHTAG_UNFOLLOW_SUCCESS = 'HASHTAG_UNFOLLOW_SUCCESS';
export const HASHTAG_UNFOLLOW_FAIL    = 'HASHTAG_UNFOLLOW_FAIL';

export const fetchHashtag = name => (dispatch, getState) => {
  dispatch(fetchHashtagRequest());

  api(getState).get(`/api/v1/tags/${name}`).then(({ data }) => {
    dispatch(fetchHashtagSuccess(name, data));
  }).catch(err => {
    dispatch(fetchHashtagFail(err));
  });
};

export const fetchHashtagRequest = () => ({
  type: HASHTAG_FETCH_REQUEST,
});

export const fetchHashtagSuccess = (name, tag) => ({
  type: HASHTAG_FETCH_SUCCESS,
  name,
  tag,
});

export const fetchHashtagFail = error => ({
  type: HASHTAG_FETCH_FAIL,
  error,
});

export const fetchFollowedHashtags = () => (dispatch, getState) => {
  dispatch(fetchFollowedHashtagsRequest());

  api(getState).get('/api/v1/followed_tags').then(response => {
    const next = getLinks(response).refs.find(link => link.rel === 'next');
    dispatch(fetchFollowedHashtagsSuccess(response.data, next ? next.uri : null));
  }).catch(err => {
    dispatch(fetchFollowedHashtagsFail(err));
  });
};

export function fetchFollowedHashtagsRequest() {
  return {
    type: FOLLOWED_HASHTAGS_FETCH_REQUEST,
  };
};

export function fetchFollowedHashtagsSuccess(followed_tags, next) {
  return {
    type: FOLLOWED_HASHTAGS_FETCH_SUCCESS,
    followed_tags,
    next,
  };
};

export function fetchFollowedHashtagsFail(error) {
  return {
    type: FOLLOWED_HASHTAGS_FETCH_FAIL,
    error,
  };
};

export function expandFollowedHashtags() {
  return (dispatch, getState) => {
    const url = getState().getIn(['followed_tags', 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowedHashtagsRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandFollowedHashtagsSuccess(response.data, next ? next.uri : null));
    }).catch(error => {
      dispatch(expandFollowedHashtagsFail(error));
    });
  };
};

export function expandFollowedHashtagsRequest() {
  return {
    type: FOLLOWED_HASHTAGS_EXPAND_REQUEST,
  };
};

export function expandFollowedHashtagsSuccess(followed_tags, next) {
  return {
    type: FOLLOWED_HASHTAGS_EXPAND_SUCCESS,
    followed_tags,
    next,
  };
};

export function expandFollowedHashtagsFail(error) {
  return {
    type: FOLLOWED_HASHTAGS_EXPAND_FAIL,
    error,
  };
};

export const followHashtag = name => (dispatch, getState) => {
  dispatch(followHashtagRequest(name));

  api(getState).post(`/api/v1/tags/${name}/follow`).then(({ data }) => {
    dispatch(followHashtagSuccess(name, data));
  }).catch(err => {
    dispatch(followHashtagFail(name, err));
  });
};

export const followHashtagRequest = name => ({
  type: HASHTAG_FOLLOW_REQUEST,
  name,
});

export const followHashtagSuccess = (name, tag) => ({
  type: HASHTAG_FOLLOW_SUCCESS,
  name,
  tag,
});

export const followHashtagFail = (name, error) => ({
  type: HASHTAG_FOLLOW_FAIL,
  name,
  error,
});

export const unfollowHashtag = name => (dispatch, getState) => {
  dispatch(unfollowHashtagRequest(name));

  api(getState).post(`/api/v1/tags/${name}/unfollow`).then(({ data }) => {
    dispatch(unfollowHashtagSuccess(name, data));
  }).catch(err => {
    dispatch(unfollowHashtagFail(name, err));
  });
};

export const unfollowHashtagRequest = name => ({
  type: HASHTAG_UNFOLLOW_REQUEST,
  name,
});

export const unfollowHashtagSuccess = (name, tag) => ({
  type: HASHTAG_UNFOLLOW_SUCCESS,
  name,
  tag,
});

export const unfollowHashtagFail = (name, error) => ({
  type: HASHTAG_UNFOLLOW_FAIL,
  name,
  error,
});
