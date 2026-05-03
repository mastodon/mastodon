import api, { getLinks } from '../api';

import { importFetchedStatuses } from './importer';

export const BOOKMARKED_STATUSES_FETCH_REQUEST = 'BOOKMARKED_STATUSES_FETCH_REQUEST';
export const BOOKMARKED_STATUSES_FETCH_SUCCESS = 'BOOKMARKED_STATUSES_FETCH_SUCCESS';
export const BOOKMARKED_STATUSES_FETCH_FAIL    = 'BOOKMARKED_STATUSES_FETCH_FAIL';

export const BOOKMARK_FOLDER_STATUSES_FETCH_REQUEST = 'BOOKMARK_FOLDER_STATUSES_FETCH_REQUEST';
export const BOOKMARK_FOLDER_STATUSES_FETCH_SUCCESS = 'BOOKMARK_FOLDER_STATUSES_FETCH_SUCCESS';
export const BOOKMARK_FOLDER_STATUSES_FETCH_FAIL    = 'BOOKMARK_FOLDER_STATUSES_FETCH_FAIL';

export const BOOKMARKED_STATUSES_EXPAND_REQUEST = 'BOOKMARKED_STATUSES_EXPAND_REQUEST';
export const BOOKMARKED_STATUSES_EXPAND_SUCCESS = 'BOOKMARKED_STATUSES_EXPAND_SUCCESS';
export const BOOKMARKED_STATUSES_EXPAND_FAIL    = 'BOOKMARKED_STATUSES_EXPAND_FAIL';

export const BOOKMARK_FOLDER_STATUSES_EXPAND_REQUEST = 'BOOKMARK_FOLDER_STATUSES_EXPAND_REQUEST';
export const BOOKMARK_FOLDER_STATUSES_EXPAND_SUCCESS = 'BOOKMARK_FOLDER_STATUSES_EXPAND_SUCCESS';
export const BOOKMARK_FOLDER_STATUSES_EXPAND_FAIL    = 'BOOKMARK_FOLDER_STATUSES_EXPAND_FAIL';

const getBookmarksListPath = (folderId) => (
  folderId ? ['status_lists', 'bookmark_folders', folderId] : ['status_lists', 'bookmarks']
);

const getBookmarksListUrl = (folderId) => (
  folderId ? `/api/v1/bookmarks/folders/${folderId}` : '/api/v1/bookmarks'
);

export function fetchBookmarkedStatuses(folderId) {
  return (dispatch, getState) => {
    const listPath = getBookmarksListPath(folderId);

    if (getState().getIn([...listPath, 'isLoading'])) {
      return;
    }

    dispatch(fetchBookmarkedStatusesRequest(folderId));

    api().get(getBookmarksListUrl(folderId)).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedStatuses(response.data));
      dispatch(fetchBookmarkedStatusesSuccess(response.data, next ? next.uri : null, folderId));
    }).catch(error => {
      dispatch(fetchBookmarkedStatusesFail(error, folderId));
    });
  };
}

export function fetchBookmarkedStatusesRequest(folderId) {
  if (folderId) {
    return {
      type: BOOKMARK_FOLDER_STATUSES_FETCH_REQUEST,
      folderId,
    };
  }

  return {
    type: BOOKMARKED_STATUSES_FETCH_REQUEST,
  };
}

export function fetchBookmarkedStatusesSuccess(statuses, next, folderId) {
  if (folderId) {
    return {
      type: BOOKMARK_FOLDER_STATUSES_FETCH_SUCCESS,
      statuses,
      next,
      folderId,
    };
  }

  return {
    type: BOOKMARKED_STATUSES_FETCH_SUCCESS,
    statuses,
    next,
  };
}

export function fetchBookmarkedStatusesFail(error, folderId) {
  if (folderId) {
    return {
      type: BOOKMARK_FOLDER_STATUSES_FETCH_FAIL,
      folderId,
      error,
    };
  }

  return {
    type: BOOKMARKED_STATUSES_FETCH_FAIL,
    error,
  };
}

export function expandBookmarkedStatuses(folderId) {
  return (dispatch, getState) => {
    const listPath = getBookmarksListPath(folderId);
    const url = getState().getIn([...listPath, 'next'], null);

    if (url === null || getState().getIn([...listPath, 'isLoading'])) {
      return;
    }

    dispatch(expandBookmarkedStatusesRequest(folderId));

    api().get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedStatuses(response.data));
      dispatch(expandBookmarkedStatusesSuccess(response.data, next ? next.uri : null, folderId));
    }).catch(error => {
      dispatch(expandBookmarkedStatusesFail(error, folderId));
    });
  };
}

export function expandBookmarkedStatusesRequest(folderId) {
  if (folderId) {
    return {
      type: BOOKMARK_FOLDER_STATUSES_EXPAND_REQUEST,
      folderId,
    };
  }

  return {
    type: BOOKMARKED_STATUSES_EXPAND_REQUEST,
  };
}

export function expandBookmarkedStatusesSuccess(statuses, next, folderId) {
  if (folderId) {
    return {
      type: BOOKMARK_FOLDER_STATUSES_EXPAND_SUCCESS,
      statuses,
      next,
      folderId,
    };
  }

  return {
    type: BOOKMARKED_STATUSES_EXPAND_SUCCESS,
    statuses,
    next,
  };
}

export function expandBookmarkedStatusesFail(error, folderId) {
  if (folderId) {
    return {
      type: BOOKMARK_FOLDER_STATUSES_EXPAND_FAIL,
      folderId,
      error,
    };
  }

  return {
    type: BOOKMARKED_STATUSES_EXPAND_FAIL,
    error,
  };
}
