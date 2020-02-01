import api from 'flavours/glitch/util/api';

export const MARKERS_FETCH_REQUEST = 'MARKERS_FETCH_REQUEST';
export const MARKERS_FETCH_SUCCESS = 'MARKERS_FETCH_SUCCESS';
export const MARKERS_FETCH_FAIL    = 'MARKERS_FETCH_FAIL';

export const submitMarkers = () => (dispatch, getState) => {
  const accessToken = getState().getIn(['meta', 'access_token'], '');
  const params      = {};

  const lastHomeId         = getState().getIn(['timelines', 'home', 'items', 0]);
  const lastNotificationId = getState().getIn(['notifications', 'lastReadId']);

  if (lastHomeId) {
    params.home = {
      last_read_id: lastHomeId,
    };
  }

  if (lastNotificationId && lastNotificationId !== '0') {
    params.notifications = {
      last_read_id: lastNotificationId,
    };
  }

  if (Object.keys(params).length === 0) {
    return;
  }

  const client = new XMLHttpRequest();

  client.open('POST', '/api/v1/markers', false);
  client.setRequestHeader('Content-Type', 'application/json');
  client.setRequestHeader('Authorization', `Bearer ${accessToken}`);
  client.send(JSON.stringify(params));
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
