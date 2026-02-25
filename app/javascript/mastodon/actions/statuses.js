import { defineMessages } from 'react-intl';

import { browserHistory } from 'mastodon/components/router';

import api from '../api';

import { showAlert } from './alerts';
import { ensureComposeIsVisible, setComposeToStatus } from './compose';
import { importFetchedStatus, importFetchedAccount } from './importer';
import { fetchContext } from './statuses_typed';
import { deleteFromTimelines } from './timelines';

export * from './statuses_typed';

export const STATUS_FETCH_REQUEST = 'STATUS_FETCH_REQUEST';
export const STATUS_FETCH_SUCCESS = 'STATUS_FETCH_SUCCESS';
export const STATUS_FETCH_FAIL    = 'STATUS_FETCH_FAIL';

export const STATUS_DELETE_REQUEST = 'STATUS_DELETE_REQUEST';
export const STATUS_DELETE_SUCCESS = 'STATUS_DELETE_SUCCESS';
export const STATUS_DELETE_FAIL    = 'STATUS_DELETE_FAIL';

export const STATUS_MUTE_REQUEST = 'STATUS_MUTE_REQUEST';
export const STATUS_MUTE_SUCCESS = 'STATUS_MUTE_SUCCESS';
export const STATUS_MUTE_FAIL    = 'STATUS_MUTE_FAIL';

export const STATUS_UNMUTE_REQUEST = 'STATUS_UNMUTE_REQUEST';
export const STATUS_UNMUTE_SUCCESS = 'STATUS_UNMUTE_SUCCESS';
export const STATUS_UNMUTE_FAIL    = 'STATUS_UNMUTE_FAIL';

export const STATUS_REVEAL   = 'STATUS_REVEAL';
export const STATUS_HIDE     = 'STATUS_HIDE';
export const STATUS_COLLAPSE = 'STATUS_COLLAPSE';

export const REDRAFT = 'REDRAFT';

export const STATUS_FETCH_SOURCE_REQUEST = 'STATUS_FETCH_SOURCE_REQUEST';
export const STATUS_FETCH_SOURCE_SUCCESS = 'STATUS_FETCH_SOURCE_SUCCESS';
export const STATUS_FETCH_SOURCE_FAIL    = 'STATUS_FETCH_SOURCE_FAIL';

export const STATUS_TRANSLATE_REQUEST = 'STATUS_TRANSLATE_REQUEST';
export const STATUS_TRANSLATE_SUCCESS = 'STATUS_TRANSLATE_SUCCESS';
export const STATUS_TRANSLATE_FAIL    = 'STATUS_TRANSLATE_FAIL';
export const STATUS_TRANSLATE_UNDO    = 'STATUS_TRANSLATE_UNDO';

const messages = defineMessages({
  deleteSuccess: { id: 'status.delete.success', defaultMessage: 'Post deleted' },
});

export function fetchStatusRequest(id, skipLoading) {
  return {
    type: STATUS_FETCH_REQUEST,
    id,
    skipLoading,
  };
}

/**
 * @param {string} id
 * @param {Object} [options]
 * @param {boolean} [options.forceFetch]
 * @param {boolean} [options.alsoFetchContext]
 * @param {string | null | undefined} [options.parentQuotePostId]
 */
export function fetchStatus(id, {
  forceFetch = false,
  alsoFetchContext = true,
  parentQuotePostId,
} = {}) {
  return (dispatch, getState) => {
    const skipLoading = !forceFetch && getState().getIn(['statuses', id], null) !== null;

    if (alsoFetchContext) {
      dispatch(fetchContext({ statusId: id }));
    }

    if (skipLoading) {
      return;
    }

    dispatch(fetchStatusRequest(id, skipLoading));

    api().get(`/api/v1/statuses/${id}`).then(response => {
      dispatch(importFetchedStatus(response.data));
      dispatch(fetchStatusSuccess(skipLoading));
    }).catch(error => {
      dispatch(fetchStatusFail(id, error, skipLoading, parentQuotePostId));
      if (error.status === 404)
        dispatch(deleteFromTimelines(id));
    });
  };
}

export function fetchStatusSuccess(skipLoading) {
  return {
    type: STATUS_FETCH_SUCCESS,
    skipLoading,
  };
}

export function fetchStatusFail(id, error, skipLoading, parentQuotePostId) {
  return {
    type: STATUS_FETCH_FAIL,
    id,
    error,
    parentQuotePostId,
    skipLoading,
    skipAlert: true,
  };
}

export function redraft(status, raw_text, quoted_status_id = null) {
  return (dispatch, getState) => {
    const maxOptions = getState().server.getIn(['server', 'configuration', 'polls', 'max_options']);

    dispatch({
      type: REDRAFT,
      status,
      raw_text,
      quoted_status_id,
      maxOptions,
    });
  };
}

export const editStatus = (id) => (dispatch, getState) => {
  let status = getState().getIn(['statuses', id]);

  if (status.get('poll')) {
    status = status.set('poll', getState().getIn(['polls', status.get('poll')]));
  }

  dispatch(fetchStatusSourceRequest());

  api().get(`/api/v1/statuses/${id}/source`).then(response => {
    dispatch(fetchStatusSourceSuccess());
    ensureComposeIsVisible(getState);
    dispatch(setComposeToStatus(status, response.data.text, response.data.spoiler_text));
  }).catch(error => {
    dispatch(fetchStatusSourceFail(error));
  });
};

export const fetchStatusSourceRequest = () => ({
  type: STATUS_FETCH_SOURCE_REQUEST,
});

export const fetchStatusSourceSuccess = () => ({
  type: STATUS_FETCH_SOURCE_SUCCESS,
});

export const fetchStatusSourceFail = error => ({
  type: STATUS_FETCH_SOURCE_FAIL,
  error,
});

export function deleteStatus(id, withRedraft = false) {
  return (dispatch, getState) => {
    let status = getState().getIn(['statuses', id]);

    if (status.get('poll')) {
      status = status.set('poll', getState().getIn(['polls', status.get('poll')]));
    }

    dispatch(deleteStatusRequest(id));

    return api().delete(`/api/v1/statuses/${id}`, { params: { delete_media: !withRedraft } }).then(response => {
      dispatch(deleteStatusSuccess(id));
      dispatch(deleteFromTimelines(id));
      dispatch(importFetchedAccount(response.data.account));

      if (withRedraft) {
        dispatch(redraft(status, response.data.text, response.data.quote?.quoted_status?.id));
        ensureComposeIsVisible(getState);
      } else {
        dispatch(showAlert({ message: messages.deleteSuccess }));
      }

      return response;
    }).catch(error => {
      dispatch(deleteStatusFail(id, error));
      throw error;
    });
  };
}

export function deleteStatusRequest(id) {
  return {
    type: STATUS_DELETE_REQUEST,
    id: id,
  };
}

export function deleteStatusSuccess(id) {
  return {
    type: STATUS_DELETE_SUCCESS,
    id: id,
  };
}

export function deleteStatusFail(id, error) {
  return {
    type: STATUS_DELETE_FAIL,
    id: id,
    error: error,
  };
}

export const updateStatus = (status, { bogusQuotePolicy }) => dispatch =>
  dispatch(importFetchedStatus(status, { bogusQuotePolicy }));

export function muteStatus(id) {
  return (dispatch) => {
    dispatch(muteStatusRequest(id));

    api().post(`/api/v1/statuses/${id}/mute`).then(() => {
      dispatch(muteStatusSuccess(id));
    }).catch(error => {
      dispatch(muteStatusFail(id, error));
    });
  };
}

export function muteStatusRequest(id) {
  return {
    type: STATUS_MUTE_REQUEST,
    id,
  };
}

export function muteStatusSuccess(id) {
  return {
    type: STATUS_MUTE_SUCCESS,
    id,
  };
}

export function muteStatusFail(id, error) {
  return {
    type: STATUS_MUTE_FAIL,
    id,
    error,
  };
}

export function unmuteStatus(id) {
  return (dispatch) => {
    dispatch(unmuteStatusRequest(id));

    api().post(`/api/v1/statuses/${id}/unmute`).then(() => {
      dispatch(unmuteStatusSuccess(id));
    }).catch(error => {
      dispatch(unmuteStatusFail(id, error));
    });
  };
}

export function unmuteStatusRequest(id) {
  return {
    type: STATUS_UNMUTE_REQUEST,
    id,
  };
}

export function unmuteStatusSuccess(id) {
  return {
    type: STATUS_UNMUTE_SUCCESS,
    id,
  };
}

export function unmuteStatusFail(id, error) {
  return {
    type: STATUS_UNMUTE_FAIL,
    id,
    error,
  };
}

export function hideStatus(ids) {
  if (!Array.isArray(ids)) {
    ids = [ids];
  }

  return {
    type: STATUS_HIDE,
    ids,
  };
}

export function revealStatus(ids) {
  if (!Array.isArray(ids)) {
    ids = [ids];
  }

  return {
    type: STATUS_REVEAL,
    ids,
  };
}

export function toggleStatusSpoilers(statusId) {
  return (dispatch, getState) => {
    const status = getState().statuses.get(statusId);

    if (!status)
      return;

    if (status.get('hidden')) {
      dispatch(revealStatus(statusId));
    } else {
      dispatch(hideStatus(statusId));
    }
  };
}

export function toggleStatusCollapse(id, isCollapsed) {
  return {
    type: STATUS_COLLAPSE,
    id,
    isCollapsed,
  };
}

export const translateStatus = id => (dispatch) => {
  dispatch(translateStatusRequest(id));

  api().post(`/api/v1/statuses/${id}/translate`).then(response => {
    dispatch(translateStatusSuccess(id, response.data));
  }).catch(error => {
    dispatch(translateStatusFail(id, error));
  });
};

export const translateStatusRequest = id => ({
  type: STATUS_TRANSLATE_REQUEST,
  id,
});

export const translateStatusSuccess = (id, translation) => ({
  type: STATUS_TRANSLATE_SUCCESS,
  id,
  translation,
});

export const translateStatusFail = (id, error) => ({
  type: STATUS_TRANSLATE_FAIL,
  id,
  error,
});

export const undoStatusTranslation = (id, pollId) => ({
  type: STATUS_TRANSLATE_UNDO,
  id,
  pollId,
});

export const navigateToStatus = (statusId) => {
  return (_dispatch, getState) => {
    const state = getState();
    const accountId = state.statuses.getIn([statusId, 'account']);
    const acct = state.accounts.getIn([accountId, 'acct']);

    if (acct) {
      browserHistory.push(`/@${acct}/${statusId}`);
    }
  };
};
