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

const openUrl = url =>
  self.clients.matchAll({ type: 'window' }).then(clientList => {
    if (clientList.length !== 0 && 'navigate' in clientList[0]) { // Chrome 42-48 does not support navigate
      const webClients = clientList
        .filter(client => /\/web\//.test(client.url))
        .sort(client => client !== 'visible');

      const visibleClient = clientList.find(client => client.visibilityState === 'visible');
      const focusedClient = clientList.find(client => client.focused);

      const client = webClients[0] || visibleClient || focusedClient || clientList[0];

      return client.navigate(url).then(client => client.focus());
    } else {
      return self.clients.openWindow(url);
    }
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
      resolve(openUrl(event.notification.data.url));
    }
  });

  event.waitUntil(reactToNotificationClick);
};

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
