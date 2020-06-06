import { fetchRelationships } from './accounts';
import api, { getLinks } from '../api';
import { importFetchedStatuses } from './importer';
import { uniq } from '../utils/uniq';

export const BOOKMARKED_STATUSES_FETCH_REQUEST = 'BOOKMARKED_STATUSES_FETCH_REQUEST';
export const BOOKMARKED_STATUSES_FETCH_SUCCESS = 'BOOKMARKED_STATUSES_FETCH_SUCCESS';
export const BOOKMARKED_STATUSES_FETCH_FAIL    = 'BOOKMARKED_STATUSES_FETCH_FAIL';

export const BOOKMARKED_STATUSES_EXPAND_REQUEST = 'BOOKMARKED_STATUSES_EXPAND_REQUEST';
export const BOOKMARKED_STATUSES_EXPAND_SUCCESS = 'BOOKMARKED_STATUSES_EXPAND_SUCCESS';
export const BOOKMARKED_STATUSES_EXPAND_FAIL    = 'BOOKMARKED_STATUSES_EXPAND_FAIL';

export function fetchBookmarkedStatuses() {
  return (dispatch, getState) => {
    if (getState().getIn(['status_lists', 'bookmarks', 'isLoading'])) {
      return;
    }

    dispatch(fetchBookmarkedStatusesRequest());

    api(getState).get('/api/v1/bookmarks').then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedStatuses(response.data));
      dispatch(fetchRelationships(uniq(response.data.map(item => item.reblog ? item.reblog.account.id : item.account.id))));
      dispatch(fetchBookmarkedStatusesSuccess(response.data, next ? next.uri : null));
    }).catch(error => {
      dispatch(fetchBookmarkedStatusesFail(error));
    });
  };
};

export function fetchBookmarkedStatusesRequest() {
  return {
    type: BOOKMARKED_STATUSES_FETCH_REQUEST,
  };
};

export function fetchBookmarkedStatusesSuccess(statuses, next) {
  return {
    type: BOOKMARKED_STATUSES_FETCH_SUCCESS,
    statuses,
    next,
  };
};

export function fetchBookmarkedStatusesFail(error) {
  return {
    type: BOOKMARKED_STATUSES_FETCH_FAIL,
    error,
  };
};

export function expandBookmarkedStatuses() {
  return (dispatch, getState) => {
    const url = getState().getIn(['status_lists', 'bookmarks', 'next'], null);

    if (url === null || getState().getIn(['status_lists', 'bookmarks', 'isLoading'])) {
      return;
    }

    dispatch(expandBookmarkedStatusesRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedStatuses(response.data));
      dispatch(fetchRelationships(uniq(response.data.map(item => item.reblog ? item.reblog.account.id : item.account.id))));
      dispatch(expandBookmarkedStatusesSuccess(response.data, next ? next.uri : null));
    }).catch(error => {
      dispatch(expandBookmarkedStatusesFail(error));
    });
  };
};

export function expandBookmarkedStatusesRequest() {
  return {
    type: BOOKMARKED_STATUSES_EXPAND_REQUEST,
  };
};

export function expandBookmarkedStatusesSuccess(statuses, next) {
  return {
    type: BOOKMARKED_STATUSES_EXPAND_SUCCESS,
    statuses,
    next,
  };
};

export function expandBookmarkedStatusesFail(error) {
  return {
    type: BOOKMARKED_STATUSES_EXPAND_FAIL,
    error,
  };
};
