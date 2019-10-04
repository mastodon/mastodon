export const submitMarkers = () => (dispatch, getState) => {
  const accessToken = getState().getIn(['meta', 'access_token'], '');
  const params      = {};

  const lastHomeId         = getState().getIn(['timelines', 'home', 'items', 0]);
  const lastNotificationId = getState().getIn(['notifications', 'items', 0, 'id']);

  if (lastHomeId) {
    params.home = {
      last_read_id: lastHomeId,
    };
  }

  if (lastNotificationId) {
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
