export const SET_BROWSER_SUPPORT = 'PUSH_NOTIFICATIONS_SET_BROWSER_SUPPORT';
export const SET_SUBSCRIPTION = 'PUSH_NOTIFICATIONS_SET_SUBSCRIPTION';
export const CLEAR_SUBSCRIPTION = 'PUSH_NOTIFICATIONS_CLEAR_SUBSCRIPTION';
export const SET_ALERTS = 'PUSH_NOTIFICATIONS_SET_ALERTS';

export function setBrowserSupport (value) {
  return {
    type: SET_BROWSER_SUPPORT,
    value,
  };
}

export function setSubscription (subscription) {
  return {
    type: SET_SUBSCRIPTION,
    subscription,
  };
}

export function clearSubscription () {
  return {
    type: CLEAR_SUBSCRIPTION,
  };
}

export function setAlerts (path, value) {
  return dispatch => {
    dispatch({
      type: SET_ALERTS,
      path,
      value,
    });
  };
}
