import api, { getLinks } from '../api';
import { importFetchedStatuses } from './importer';

export const FAVOURITED_STATUSES_FETCH_REQUEST = 'FAVOURITED_STATUSES_FETCH_REQUEST';
export const FAVOURITED_STATUSES_FETCH_SUCCESS = 'FAVOURITED_STATUSES_FETCH_SUCCESS';
export const FAVOURITED_STATUSES_FETCH_FAIL    = 'FAVOURITED_STATUSES_FETCH_FAIL';

export const FAVOURITED_STATUSES_EXPAND_REQUEST = 'FAVOURITED_STATUSES_EXPAND_REQUEST';
export const FAVOURITED_STATUSES_EXPAND_SUCCESS = 'FAVOURITED_STATUSES_EXPAND_SUCCESS';
export const FAVOURITED_STATUSES_EXPAND_FAIL    = 'FAVOURITED_STATUSES_EXPAND_FAIL';

export function fetchFavouritedStatuses() {
  return (dispatch, getState) => {
    if (getState().getIn(['status_lists', 'favourites', 'isLoading'])) {
      return;
    }

    dispatch(fetchFavouritedStatusesRequest());

    api(getState).get('/api/v1/favourites').then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedStatuses(response.data));
      dispatch(fetchFavouritedStatusesSuccess(response.data, next ? next.uri : null));
    }).catch(error => {
      dispatch(fetchFavouritedStatusesFail(error));
    });
  };
}

export function fetchFavouritedStatusesRequest() {
  return {
    type: FAVOURITED_STATUSES_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchFavouritedStatusesSuccess(statuses, next) {
  return {
    type: FAVOURITED_STATUSES_FETCH_SUCCESS,
    statuses,
    next,
    skipLoading: true,
  };
}

export function fetchFavouritedStatusesFail(error) {
  return {
    type: FAVOURITED_STATUSES_FETCH_FAIL,
    error,
    skipLoading: true,
  };
}

export function expandFavouritedStatuses() {
  return (dispatch, getState) => {
    const url = getState().getIn(['status_lists', 'favourites', 'next'], null);

    if (url === null || getState().getIn(['status_lists', 'favourites', 'isLoading'])) {
      return;
    }

    dispatch(expandFavouritedStatusesRequest());

    api(getState).get(url).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(importFetchedStatuses(response.data));
      dispatch(expandFavouritedStatusesSuccess(response.data, next ? next.uri : null));
    }).catch(error => {
      dispatch(expandFavouritedStatusesFail(error));
    });
  };
}

export function expandFavouritedStatusesRequest() {
  return {
    type: FAVOURITED_STATUSES_EXPAND_REQUEST,
  };
}

export function expandFavouritedStatusesSuccess(statuses, next) {
  return {
    type: FAVOURITED_STATUSES_EXPAND_SUCCESS,
    statuses,
    next,
  };
}

export function expandFavouritedStatusesFail(error) {
  return {
    type: FAVOURITED_STATUSES_EXPAND_FAIL,
    error,
  };
}
