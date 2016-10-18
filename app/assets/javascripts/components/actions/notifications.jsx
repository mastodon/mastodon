export const NOTIFICATION_SHOW    = 'NOTIFICATION_SHOW';
export const NOTIFICATION_DISMISS = 'NOTIFICATION_DISMISS';
export const NOTIFICATION_CLEAR   = 'NOTIFICATION_CLEAR';

export function dismissNotification(notification) {
  return {
    type: NOTIFICATION_DISMISS,
    notification: notification
  };
};

export function clearNotifications() {
  return {
    type: NOTIFICATION_CLEAR
  };
};

export function showNotification(title, message) {
  return {
    type: NOTIFICATION_SHOW,
    title: title,
    message: message
  };
};
