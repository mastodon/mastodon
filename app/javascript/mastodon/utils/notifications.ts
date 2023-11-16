// Handles browser quirks, based on
// https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API/Using_the_Notifications_API

interface WritableNotification {
  permission: NotificationPermission;
}

const checkNotificationPromise = () => {
  try {
    // eslint-disable-next-line @typescript-eslint/no-floating-promises, promise/catch-or-return, promise/valid-params
    Notification.requestPermission().then();
  } catch {
    return false;
  }

  return true;
};

const handlePermission = (
  permission: NotificationPermission,
  callback: NotificationPermissionCallback,
) => {
  // Whatever the user answers, we make sure Chrome stores the information
  if (!('permission' in (Notification as object))) {
    (Notification as WritableNotification).permission = permission;
  }

  callback(Notification.permission);
};

export const requestNotificationPermission = (
  callback: NotificationPermissionCallback,
) => {
  if (checkNotificationPromise()) {
    Notification.requestPermission()
      // eslint-disable-next-line @typescript-eslint/no-confusing-void-expression
      .then((permission) => handlePermission(permission, callback))
      .catch(console.warn);
  } else {
    // eslint-disable-next-line @typescript-eslint/no-floating-promises
    Notification.requestPermission((permission) =>
      // eslint-disable-next-line @typescript-eslint/no-confusing-void-expression
      handlePermission(permission, callback),
    );
  }
};
