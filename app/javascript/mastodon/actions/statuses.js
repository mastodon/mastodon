import { defineMessages } from 'react-intl';

import { browserHistory } from 'mastodon/components/router';

import api from '../api';

import { showAlert } from './alerts';
import { setComposeToStatus } from './compose';
import { importFetchedStatus, importFetchedAccount } from './importer';
import { fetchContext } from './statuses_typed';
import { deleteFromTimelines } from './timelines';

export * from './statuses_typed';

export const STATUS_FETCH_REQUEST = 'STATUS_FETCH_REQUEST';
export const STATUS_FETCH_FAIL    = 'STATUS_FETCH_FAIL';

export const STATUS_DELETE_SUCCESS = 'STATUS_DELETE_SUCCESS';

export const STATUS_MUTE_SUCCESS = 'STATUS_MUTE_SUCCESS';

export const STATUS_UNMUTE_SUCCESS = 'STATUS_UNMUTE_SUCCESS';

export const STATUS_REVEAL   = 'STATUS_REVEAL';
export const STATUS_HIDE     = 'STATUS_HIDE';
export const STATUS_COLLAPSE = 'STATUS_COLLAPSE';

export const REDRAFT = 'REDRAFT';

export const STATUS_TRANSLATE_REQUEST = 'STATUS_TRANSLATE_REQUEST';
export const STATUS_TRANSLATE_SUCCESS = 'STATUS_TRANSLATE_SUCCESS';
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
    }).catch(error => {
      dispatch(fetchStatusFail(id, error, skipLoading, parentQuotePostId));
      if (error.status === 404)
        dispatch(deleteFromTimelines(id));
    });
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
    const maxOptions = getState().server.server.item?.configuration.polls.max_options;

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

  api().get(`/api/v1/statuses/${id}/source`).then(response => {
    dispatch(setComposeToStatus(status, response.data.text, response.data.spoiler_text));
  }).catch(error => {
  });
};

export function deleteStatus(id, withRedraft = false) {
  return (dispatch, getState) => {
    let status = getState().getIn(['statuses', id]);

    if (status.get('poll')) {
      status = status.set('poll', getState().getIn(['polls', status.get('poll')]));
    }

    return api().delete(`/api/v1/statuses/${id}`, { params: { delete_media: !withRedraft } }).then(response => {
      dispatch(deleteStatusSuccess(id));
      dispatch(deleteFromTimelines(id));
      dispatch(importFetchedAccount(response.data.account));

      if (withRedraft) {
        dispatch(redraft(status, response.data.text, response.data.quote?.quoted_status?.id));
      } else {
        dispatch(showAlert({ message: messages.deleteSuccess }));
      }

      return response;
    }).catch(error => {
      throw error;
    });
  };
}

export function deleteStatusSuccess(id) {
  return {
    type: STATUS_DELETE_SUCCESS,
    id: id,
  };
}


export const updateStatus = (status, { bogusQuotePolicy }) => dispatch =>
  dispatch(importFetchedStatus(status, { bogusQuotePolicy }));

export function muteStatus(id) {
  return (dispatch) => {
    api().post(`/api/v1/statuses/${id}/mute`).then(() => {
      dispatch(muteStatusSuccess(id));
    }).catch(() => {});
  };
}

export function muteStatusSuccess(id) {
  return {
    type: STATUS_MUTE_SUCCESS,
    id,
  };
}

export function unmuteStatus(id) {
  return (dispatch) => {
    api().post(`/api/v1/statuses/${id}/unmute`).then(() => {
      dispatch(unmuteStatusSuccess(id));
    }).catch(() => {});
  };
}

export function unmuteStatusSuccess(id) {
  return {
    type: STATUS_UNMUTE_SUCCESS,
    id,
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
  }).catch(() => {});
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
