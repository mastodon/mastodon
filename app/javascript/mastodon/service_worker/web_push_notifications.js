const handlePush = (event) => {
  const options = event.data.json();

  options.body = options.data.nsfw || options.data.content;
  options.image = options.image || undefined; // Null results in a network request (404)
  options.timestamp = options.timestamp && new Date(options.timestamp);

  const expandAction = options.data.actions.find(action => action.todo === 'expand');

  if (expandAction) {
    options.actions = [expandAction];
    options.hiddenActions = options.data.actions.filter(action => action !== expandAction);

    options.data.hiddenImage = options.image;
    options.image = undefined;
  } else {
    options.actions = options.data.actions;
  }

  event.waitUntil(self.registration.showNotification(options.title, options));
};

const cloneNotification = (notification) => {
  const clone = {  };

  for(var k in notification) {
    clone[k] = notification[k];
  }

  return clone;
};

const expandNotification = (notification) => {
  const nextNotification = cloneNotification(notification);

  nextNotification.body = notification.data.content;
  nextNotification.image = notification.data.hiddenImage;
  nextNotification.actions = notification.data.actions.filter(action => action.todo !== 'expand');

  return self.registration.showNotification(nextNotification.title, nextNotification);
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

  const nextNotification = cloneNotification(notification);

  nextNotification.actions = actions;

  return self.registration.showNotification(nextNotification.title, nextNotification);
};

const handleNotificationClick = (event) => {
  const reactToNotificationClick = new Promise((resolve, reject) => {
    if (event.action) {
      const action = event.notification.data.actions.find(({ action }) => action === event.action);

      if (action.todo === 'expand') {
        resolve(expandNotification(event.notification));
      } else if (action.todo === 'request') {
        resolve(makeRequest(event.notification, action)
          .then(() => removeActionFromNotification(event.notification, action)));
      } else {
        reject(`Unknown action: ${action.todo}`);
      }
    } else {
      event.notification.close();
      resolve(self.clients.openWindow(event.notification.data.url));
    }
  });

  event.waitUntil(reactToNotificationClick);
};

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
