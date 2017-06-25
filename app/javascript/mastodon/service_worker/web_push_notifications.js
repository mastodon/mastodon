const handlePush = (event) => {
  const { title, options } = event.data.json();

  options.icon = options.icon || '/android-chrome-192x192.png';
  options.timestamp = options.timestamp && new Date(options.timestamp);
  options.actions = options.data.actions;

  event.waitUntil(self.registration.showNotification(title, options));
};

const makeRequest = (notification, action) =>
  fetch(action.action, {
    headers: {
      'Authorization': `Bearer ${notification.data.access_token}`,
      'Content-Type': 'application/json',
    },
    method: action.method,
    credentials: 'include',
  });

const removeActionFromNotification = (notification, action) => {
  const actions = notification.actions.filter(act => act.action !== action.action);

  const nextNotification = {  };

  for(var k in notification) {
    nextNotification[k] = notification[k];
  }

  nextNotification.actions = actions;

  return self.registration.showNotification(nextNotification.title, nextNotification);
};

const handleNotificationClick = (event) => {
  const reactToNotificationClick = new Promise((resolve, reject) => {
    if (event.action) {
      const action = event.notification.data.actions.find(({ action }) => action === event.action);

      if (action.type === 'request') {
        return makeRequest(event.notification, action)
          .then(() => removeActionFromNotification(event.notification, action))
          .then(resolve)
          .catch(reject);
      }

      return null;
    } else {
      event.notification.close();
      return self.clients.openWindow(event.notification.data.url);
    }
  });

  event.waitUntil(reactToNotificationClick);
};

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
