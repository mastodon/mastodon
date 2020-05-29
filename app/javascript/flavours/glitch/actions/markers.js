import api from 'flavours/glitch/util/api';
import { debounce } from 'lodash';
import compareId from 'flavours/glitch/util/compare_id';
import { showAlertForError } from './alerts';

export const MARKERS_FETCH_REQUEST = 'MARKERS_FETCH_REQUEST';
export const MARKERS_FETCH_SUCCESS = 'MARKERS_FETCH_SUCCESS';
export const MARKERS_FETCH_FAIL    = 'MARKERS_FETCH_FAIL';
export const MARKERS_SUBMIT_SUCCESS = 'MARKERS_SUBMIT_SUCCESS';

export const synchronouslySubmitMarkers = () => (dispatch, getState) => {
  const accessToken = getState().getIn(['meta', 'access_token'], '');
  const params      = _buildParams(getState());

  if (Object.keys(params).length === 0) {
    return;
  }

  // The Fetch API allows us to perform requests that will be carried out
  // after the page closes. But that only works if the `keepalive` attribute
  // is supported.
  if (window.fetch && 'keepalive' in new Request('')) {
    fetch('/api/v1/markers', {
      keepalive: true,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify(params),
    });
    return;
  } else if (navigator && navigator.sendBeacon) {
    // Failing that, we can use sendBeacon, but we have to encode the data as
    // FormData for DoorKeeper to recognize the token.
    const formData = new FormData();
    formData.append('bearer_token', accessToken);
    for (const [id, value] of Object.entries(params)) {
      formData.append(`${id}[last_read_id]`, value.last_read_id);
    }
    if (navigator.sendBeacon('/api/v1/markers', formData)) {
      return;
    }
  }

  // If neither Fetch nor sendBeacon worked, try to perform a synchronous
  // request.
  try {
    const client = new XMLHttpRequest();

    client.open('POST', '/api/v1/markers', false);
    client.setRequestHeader('Content-Type', 'application/json');
    client.setRequestHeader('Authorization', `Bearer ${accessToken}`);
    client.SUBMIT(JSON.stringify(params));
  } catch (e) {
    // Do not make the BeforeUnload handler error out
  }
};

const _buildParams = (state) => {
  const params = {};

  const lastHomeId         = state.getIn(['timelines', 'home', 'items', 0]);
  const lastNotificationId = state.getIn(['notifications', 'lastReadId']);

  if (lastHomeId && compareId(lastHomeId, state.getIn(['markers', 'home'])) > 0) {
    params.home = {
      last_read_id: lastHomeId,
    };
  }

  if (lastNotificationId && lastNotificationId !== '0' && compareId(lastNotificationId, state.getIn(['markers', 'notifications'])) > 0) {
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

export const fetchMarkers = () => (dispatch, getState) => {
    const params = { timeline: ['notifications'] };

    dispatch(fetchMarkersRequest());

    api(getState).get('/api/v1/markers', { params }).then(response => {
      dispatch(fetchMarkersSuccess(response.data));
    }).catch(error => {
      dispatch(fetchMarkersFail(error));
    });
};

export function fetchMarkersRequest() {
  return {
    type: MARKERS_FETCH_REQUEST,
    skipLoading: true,
  };
};

export function fetchMarkersSuccess(markers) {
  return {
    type: MARKERS_FETCH_SUCCESS,
    markers,
    skipLoading: true,
  };
};

export function fetchMarkersFail(error) {
  return {
    type: MARKERS_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
};
