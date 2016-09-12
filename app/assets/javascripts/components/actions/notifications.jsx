export const NOTIFICATION_DISMISS = 'NOTIFICATION_DISMISS';

export function dismissNotification(notification) {
  return {
    type: NOTIFICATION_DISMISS,
    notification: notification
  };
};
