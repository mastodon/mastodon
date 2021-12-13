import api from '../api';
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
  dispatch(fetchTrendingStatusesRequest());

  api(getState).get('/api/v1/trends/statuses').then(({ data }) => {
    dispatch(importFetchedStatuses(data));
    dispatch(fetchTrendingStatusesSuccess(data));
  }).catch(err => dispatch(fetchTrendingStatusesFail(err)));
};

export const fetchTrendingStatusesRequest = () => ({
  type: TRENDS_STATUSES_FETCH_REQUEST,
  skipLoading: true,
});

export const fetchTrendingStatusesSuccess = statuses => ({
  type: TRENDS_STATUSES_FETCH_SUCCESS,
  statuses,
  skipLoading: true,
});

export const fetchTrendingStatusesFail = error => ({
  type: TRENDS_STATUSES_FETCH_FAIL,
  error,
  skipLoading: true,
  skipAlert: true,
});
