import axios from 'axios';

export const SET_BROWSER_SUPPORT = 'PUSH_NOTIFICATIONS_SET_BROWSER_SUPPORT';
export const SET_SUBSCRIPTION = 'PUSH_NOTIFICATIONS_SET_SUBSCRIPTION';
export const CLEAR_SUBSCRIPTION = 'PUSH_NOTIFICATIONS_CLEAR_SUBSCRIPTION';
export const ALERTS_CHANGE = 'PUSH_NOTIFICATIONS_ALERTS_CHANGE';

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

export function changeAlerts(key, value) {
  return dispatch => {
    dispatch({
      type: ALERTS_CHANGE,
      key,
      value,
    });

    dispatch(saveSettings());
  };
}

export function saveSettings() {
  return (_, getState) => {
    const state = getState().get('push_notifications');
    const subscription = state.get('subscription');
    const alerts = state.get('alerts');

    axios.put(`/api/web/push_subscriptions/${subscription.get('id')}`, {
      data: {
        alerts,
      },
    });
  };
}
