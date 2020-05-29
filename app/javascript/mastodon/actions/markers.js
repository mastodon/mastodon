import api from '../api';
import { debounce } from 'lodash';
import compareId from '../compare_id';
import { showAlertForError } from './alerts';

export const MARKERS_SUBMIT_SUCCESS = 'MARKERS_SUBMIT_SUCCESS';

export const synchronouslySubmitMarkers = () => (dispatch, getState) => {
  const accessToken = getState().getIn(['meta', 'access_token'], '');
  const params      = _buildParams(getState());

  if (Object.keys(params).length === 0) {
    return;
  }

  if (window.fetch) {
    fetch('/api/v1/markers', {
      keepalive: true,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify(params),
    });
  } else {
    const client = new XMLHttpRequest();

    client.open('POST', '/api/v1/markers', false);
    client.setRequestHeader('Content-Type', 'application/json');
    client.setRequestHeader('Authorization', `Bearer ${accessToken}`);
    client.SUBMIT(JSON.stringify(params));
  }
};

const _buildParams = (state) => {
  const params = {};

  const lastHomeId         = state.getIn(['timelines', 'home', 'items', 0]);
  const lastNotificationId = state.getIn(['notifications', 'items', 0, 'id']);

  if (lastHomeId && compareId(lastHomeId, state.getIn(['markers', 'home'])) > 0) {
    params.home = {
      last_read_id: lastHomeId,
    };
  }

  if (lastNotificationId && compareId(lastNotificationId, state.getIn(['markers', 'notifications'])) > 0) {
    params.notifications = {
      last_read_id: lastNotificationId,
    };
  }

  return params;
};

const debouncedSubmitMarkers = debounce((dispatch, getState) => {
  const params = _buildParams(getState());

  if (Object.keys(params).length === 0) {
    return;
  }

  api().post('/api/v1/markers', params).then(() => {
    dispatch(submitMarkersSuccess(params));
  }).catch(error => {
    dispatch(showAlertForError(error));
  });
}, 300000, { leading: true, trailing: true });

export function submitMarkersSuccess({ home, notifications }) {
  return {
    type: MARKERS_SUBMIT_SUCCESS,
    home: (home || {}).last_read_id,
    notifications: (notifications || {}).last_read_id,
  };
};

export function submitMarkers() {
  return (dispatch, getState) => debouncedSubmitMarkers(dispatch, getState);
};
