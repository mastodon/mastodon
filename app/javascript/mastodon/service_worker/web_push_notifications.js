const MAX_NOTIFICATIONS = 5;
const GROUP_TAG = 'tag';

// Avoid loading intl-messageformat and dealing with locales in the ServiceWorker
const formatGroupTitle = (message, count) => message.replace('%{count}', count);

const notify = options =>
  self.registration.getNotifications().then(notifications => {
    if (notifications.length === MAX_NOTIFICATIONS) {
      // Reached the maximum number of notifications, proceed with grouping
      const group = {
        title: formatGroupTitle(options.data.message, notifications.length + 1),
        body: notifications
          .sort((n1, n2) => n1.timestamp < n2.timestamp)
          .map(notification => notification.title).join('\n'),
        badge: '/badge.png',
        icon: '/android-chrome-192x192.png',
        tag: GROUP_TAG,
        data: {
          url: (new URL('/web/notifications', self.location)).href,
          count: notifications.length + 1,
          message: options.data.message,
        },
      };

      notifications.forEach(notification => notification.close());

      return self.registration.showNotification(group.title, group);
    } else if (notifications.length === 1 && notifications[0].tag === GROUP_TAG) {
      // Already grouped, proceed with appending the notification to the group
      const group = cloneNotification(notifications[0]);

      group.title = formatGroupTitle(group.data.message, group.data.count + 1);
      group.body = `${options.title}\n${group.body}`;
      group.data = { ...group.data, count: group.data.count + 1 };

      return self.registration.showNotification(group.title, group);
    }

    return self.registration.showNotification(options.title, options);
  });

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

  event.waitUntil(notify(options));
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

const findBestClient = clients => {
  const focusedClient = clients.find(client => client.focused);
  const visibleClient = clients.find(client => client.visibilityState === 'visible');

  return focusedClient || visibleClient || clients[0];
};

const openUrl = url =>
  self.clients.matchAll({ type: 'window' }).then(clientList => {
    if (clientList.length !== 0) {
      const webClients = clientList.filter(client => /\/web\//.test(client.url));

      if (webClients.length !== 0) {
        const client = findBestClient(webClients);

        const { pathname } = new URL(url);

        if (pathname.startsWith('/web/')) {
          return client.focus().then(client => client.postMessage({
            type: 'navigate',
            path: pathname.slice('/web/'.length - 1),
          }));
        }
      } else if ('navigate' in clientList[0]) { // Chrome 42-48 does not support navigate
        const client = findBestClient(clientList);

        return client.navigate(url).then(client => client.focus());
      }
    }

    return self.clients.openWindow(url);
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
