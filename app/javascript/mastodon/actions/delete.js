import { defineMessages } from 'react-intl';

import api from '../api';

import { showAlert } from './alerts';
import { ensureComposeIsVisible } from './compose';
import { importFetchedAccount } from './importer';
import { redraft } from './statuses';
import { deleteFromTimelines } from './timelines';

export const STATUS_DELETE_REQUEST = 'STATUS_DELETE_REQUEST';
export const STATUS_DELETE_SUCCESS = 'STATUS_DELETE_SUCCESS';
export const STATUS_DELETE_FAIL    = 'STATUS_DELETE_FAIL';

const messages = defineMessages({
  deleteSuccess: { id: 'status.delete.success', defaultMessage: 'Post deleted' },
});

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


export function deleteStatus(id, withRedraft = false, successCallback) {
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
        dispatch(redraft(status, response.data.text));
        ensureComposeIsVisible(getState);
      } else {
        dispatch(showAlert({ message: messages.deleteSuccess }));
      }

      if (typeof successCallback === 'function') {
        successCallback(response);
      }

      return response;
    }).catch(error => {
      dispatch(deleteStatusFail(id, error));
      throw error;
    });
  };
}
