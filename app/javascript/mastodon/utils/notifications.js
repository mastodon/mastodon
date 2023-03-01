// Handles browser quirks, based on
// https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API/Using_the_Notifications_API

const checkNotificationPromise = () => {
  try {
    // eslint-disable-next-line promise/catch-or-return
    Notification.requestPermission().then();
  } catch(e) {
    return false;
  }

  return true;
};

const handlePermission = (permission, callback) => {
  // Whatever the user answers, we make sure Chrome stores the information
  if(!('permission' in Notification)) {
    Notification.permission = permission;
  }

  callback(Notification.permission);
};

export const requestNotificationPermission = (callback) => {
  if (checkNotificationPromise()) {
    Notification.requestPermission().then((permission) => handlePermission(permission, callback)).catch(console.warn);
  } else {
    Notification.requestPermission((permission) => handlePermission(permission, callback));
  }
};
