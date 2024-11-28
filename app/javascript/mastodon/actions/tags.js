import api, { getLinks } from '../api';

export const FOLLOWED_HASHTAGS_FETCH_REQUEST = 'FOLLOWED_HASHTAGS_FETCH_REQUEST';
export const FOLLOWED_HASHTAGS_FETCH_SUCCESS = 'FOLLOWED_HASHTAGS_FETCH_SUCCESS';
export const FOLLOWED_HASHTAGS_FETCH_FAIL    = 'FOLLOWED_HASHTAGS_FETCH_FAIL';

export const FOLLOWED_HASHTAGS_EXPAND_REQUEST = 'FOLLOWED_HASHTAGS_EXPAND_REQUEST';
export const FOLLOWED_HASHTAGS_EXPAND_SUCCESS = 'FOLLOWED_HASHTAGS_EXPAND_SUCCESS';
export const FOLLOWED_HASHTAGS_EXPAND_FAIL    = 'FOLLOWED_HASHTAGS_EXPAND_FAIL';

export const fetchFollowedHashtags = () => (dispatch) => {
  dispatch(fetchFollowedHashtagsRequest());

  api().get('/api/v1/followed_tags').then(response => {
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
}

export function fetchFollowedHashtagsSuccess(followed_tags, next) {
  return {
    type: FOLLOWED_HASHTAGS_FETCH_SUCCESS,
    followed_tags,
    next,
  };
}

export function fetchFollowedHashtagsFail(error) {
  return {
    type: FOLLOWED_HASHTAGS_FETCH_FAIL,
    error,
  };
}

export function expandFollowedHashtags() {
  return (dispatch, getState) => {
    const url = getState().getIn(['followed_tags', 'next']);

    if (url === null) {
      return;
    }

    dispatch(expandFollowedHashtagsRequest());

    api().get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandFollowedHashtagsSuccess(response.data, next ? next.uri : null));
    }).catch(error => {
      dispatch(expandFollowedHashtagsFail(error));
    });
  };
}

export function expandFollowedHashtagsRequest() {
  return {
    type: FOLLOWED_HASHTAGS_EXPAND_REQUEST,
  };
}

export function expandFollowedHashtagsSuccess(followed_tags, next) {
  return {
    type: FOLLOWED_HASHTAGS_EXPAND_SUCCESS,
    followed_tags,
    next,
  };
}

export function expandFollowedHashtagsFail(error) {
  return {
    type: FOLLOWED_HASHTAGS_EXPAND_FAIL,
    error,
  };
}
