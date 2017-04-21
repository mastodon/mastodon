export const ALERT_SHOW    = 'ALERT_SHOW';
export const ALERT_DISMISS = 'ALERT_DISMISS';
export const ALERT_CLEAR   = 'ALERT_CLEAR';

export function dismissAlert(alert) {
  return {
    type: ALERT_DISMISS,
    alert
  };
};

export function clearAlert() {
  return {
    type: ALERT_CLEAR
  };
};

export function showAlert(title, message) {
  return {
    type: ALERT_SHOW,
    title,
    message
  };
};
