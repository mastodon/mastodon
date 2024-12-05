/**
 * Tries Notification.requestPermission, console warning instead of rejecting on error.
 * @param callback Runs with the permission result on completion.
 */
export const requestNotificationPermission = async (
  callback: NotificationPermissionCallback,
) => {
  try {
    callback(await Notification.requestPermission());
  } catch (error) {
    console.warn(error);
  }
};
