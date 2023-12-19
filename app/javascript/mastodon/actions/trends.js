import api, { getLinks } from '../api';

import { importFetchedStatuses } from './importer';

export const TRENDS_TAGS_FETCH_REQUEST = 'TRENDS_TAGS_FETCH_REQUEST';
export const TRENDS_TAGS_FETCH_SUCCESS = 'TRENDS_TAGS_FETCH_SUCCESS';
export const TRENDS_TAGS_FETCH_FAIL    = 'TRENDS_TAGS_FETCH_FAIL';

export const TRENDS_LINKS_FETCH_REQUEST = 'TRENDS_LINKS_FETCH_REQUEST';
export const TRENDS_LINKS_FETCH_SUCCESS = 'TRENDS_LINKS_FETCH_SUCCESS';
export const TRENDS_LINKS_FETCH_FAIL    = 'TRENDS_LINKS_FETCH_FAIL';

export const TRENDS_STATUSES_FETCH_REQUEST = 'TRENDS_STATUSES_FETCH_REQUEST';
export const TRENDS_STATUSES_FETCH_SUCCESS = 'TRENDS_STATUSES_FETCH_SUCCESS';
export const TRENDS_STATUSES_FETCH_FAIL    = 'TRENDS_STATUSES_FETCH_FAIL';

export const TRENDS_STATUSES_EXPAND_REQUEST = 'TRENDS_STATUSES_EXPAND_REQUEST';
export const TRENDS_STATUSES_EXPAND_SUCCESS = 'TRENDS_STATUSES_EXPAND_SUCCESS';
export const TRENDS_STATUSES_EXPAND_FAIL    = 'TRENDS_STATUSES_EXPAND_FAIL';

export const fetchTrendingHashtags = () => (dispatch, getState) => {
  dispatch(fetchTrendingHashtagsRequest());

  api(getState)
    .get('/api/v1/trends/tags')
    .then(({ data }) => dispatch(fetchTrendingHashtagsSuccess(data)))
    .catch(err => dispatch(fetchTrendingHashtagsFail(err)));
};

export const fetchTrendingHashtagsRequest = () => ({
  type: TRENDS_TAGS_FETCH_REQUEST,
  skipLoading: true,
});

export const fetchTrendingHashtagsSuccess = trends => ({
  type: TRENDS_TAGS_FETCH_SUCCESS,
  trends,
  skipLoading: true,
});

export const fetchTrendingHashtagsFail = error => ({
  type: TRENDS_TAGS_FETCH_FAIL,
  error,
  skipLoading: true,
  skipAlert: true,
});

export const fetchTrendingLinks = () => (dispatch, getState) => {
  dispatch(fetchTrendingLinksRequest());

  api(getState)
    .get('/api/v1/trends/links')
    .then(({ data }) => dispatch(fetchTrendingLinksSuccess(data)))
    .catch(err => dispatch(fetchTrendingLinksFail(err)));
};

export const fetchTrendingLinksRequest = () => ({
  type: TRENDS_LINKS_FETCH_REQUEST,
  skipLoading: true,
});

export const fetchTrendingLinksSuccess = trends => ({
  type: TRENDS_LINKS_FETCH_SUCCESS,
  trends,
  skipLoading: true,
});

export const fetchTrendingLinksFail = error => ({
  type: TRENDS_LINKS_FETCH_FAIL,
  error,
  skipLoading: true,
  skipAlert: true,
});

export const fetchTrendingStatuses = () => (dispatch, getState) => {
  if (getState().getIn(['status_lists', 'trending', 'isLoading'])) {
    return;
  }

  dispatch(fetchTrendingStatusesRequest());

  api(getState).get('/api/v1/trends/statuses').then(response => {
    const next = getLinks(response).refs.find(link => link.rel === 'next');
    dispatch(importFetchedStatuses(response.data));
    dispatch(fetchTrendingStatusesSuccess(response.data, next ? next.uri : null));
  }).catch(err => dispatch(fetchTrendingStatusesFail(err)));
};

export const fetchTrendingStatusesRequest = () => ({
  type: TRENDS_STATUSES_FETCH_REQUEST,
  skipLoading: true,
});

export const fetchTrendingStatusesSuccess = (statuses, next) => ({
  type: TRENDS_STATUSES_FETCH_SUCCESS,
  statuses,
  next,
  skipLoading: true,
});

export const fetchTrendingStatusesFail = error => ({
  type: TRENDS_STATUSES_FETCH_FAIL,
  error,
  skipLoading: true,
  skipAlert: true,
});


export const expandTrendingStatuses = () => (dispatch, getState) => {
  const url = getState().getIn(['status_lists', 'trending', 'next'], null);

  if (url === null || getState().getIn(['status_lists', 'trending', 'isLoading'])) {
    return;
  }

  dispatch(expandTrendingStatusesRequest());

  api(getState).get(url).then(response => {
    const next = getLinks(response).refs.find(link => link.rel === 'next');
    dispatch(importFetchedStatuses(response.data));
    dispatch(expandTrendingStatusesSuccess(response.data, next ? next.uri : null));
  }).catch(error => {
    dispatch(expandTrendingStatusesFail(error));
  });
};

export const expandTrendingStatusesRequest = () => ({
  type: TRENDS_STATUSES_EXPAND_REQUEST,
});

export const expandTrendingStatusesSuccess = (statuses, next) => ({
  type: TRENDS_STATUSES_EXPAND_SUCCESS,
  statuses,
  next,
});

export const expandTrendingStatusesFail = error => ({
  type: TRENDS_STATUSES_EXPAND_FAIL,
  error,
});
