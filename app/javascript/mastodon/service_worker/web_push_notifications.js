import IntlMessageFormat from 'intl-messageformat';
import locales from './web_push_locales';

const MAX_NOTIFICATIONS = 5;
const GROUP_TAG = 'tag';

const notify = options =>
  self.registration.getNotifications().then(notifications => {
    if (notifications.length === MAX_NOTIFICATIONS) { // Reached the maximum number of notifications, proceed with grouping
      const group = {
        title: formatMessage('notifications.group', options.data.preferred_locale, { count: notifications.length + 1 }),
        body: notifications.sort((n1, n2) => n1.timestamp < n2.timestamp).map(notification => notification.title).join('\n'),
        badge: '/badge.png',
        icon: '/android-chrome-192x192.png',
        tag: GROUP_TAG,
        data: {
          url: (new URL('/web/notifications', self.location)).href,
          count: notifications.length + 1,
          preferred_locale: options.data.preferred_locale,
        },
      };

      notifications.forEach(notification => notification.close());

      return self.registration.showNotification(group.title, group);
    } else if (notifications.length === 1 && notifications[0].tag === GROUP_TAG) { // Already grouped, proceed with appending the notification to the group
      const group = { ...notifications[0] };

      group.title = formatMessage('notifications.group', options.data.preferred_locale, { count: notifications.length + 1 });
      group.body  = `${options.title}\n${group.body}`;
      group.data  = { ...group.data, count: group.data.count + 1 };

      return self.registration.showNotification(group.title, group);
    }

    return self.registration.showNotification(options.title, options);
  });

const fetchFromApi = (path, method, accessToken) => {
  const url = (new URL(path, self.location)).href;

  return fetch(url, {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },

    method: method,
    credentials: 'include',
  });
};

const formatMessage = (messageId, locale, values = {}) =>
  (new IntlMessageFormat(locales[locale][messageId], locale)).format(values);

const handlePush = (event) => {
  const { access_token, notification_id, preferred_locale } = event.data.json();

  event.waitUntil(fetchFromApi(`/api/v1/notifications/${notification_id}`, 'get', access_token)
    .then(notification => {
      const options = {};

      options.title     = formatMessage(`notification.${notification.type}`, preferred_locale, { name: notification.account.display_name.length > 0 ? notification.account.display_name : notification.account.username });
      options.body      = notification.target_status && notification.target_status.content;
      options.icon      = notification.from_account.avatar_static;
      options.timestamp = notification.created_at && new Date(notification.created_at);
      options.tag       = notification_id;
      options.badge     = '/badge.png';
      options.image     = notification.target_status && notification.target_status.media_attachments.length > 0 && notification.target_status.media_attachments[0].preview_url || undefined;
      options.data      = { preferred_locale, url: notification.target_status ? `/web/statuses/${notification.target_status.id}` : `/web/accounts/${notification.from_account.id}` };

      if (notification.target_status && notification.target_status.sensitive) {
        options.data.hiddenBody  = notification.target_status.content;
        options.data.hiddenImage = notification.target_status.media_attachments.length > 0 && notification.target_status.media_attachments[0].preview_url;

        options.body    = undefined;
        options.image   = undefined;

        options.actions = [
          {
            action: 'expand',
            icon: '/web-push-icon_expand.png',
            title: formatMessage('status.show_more', preferred_locale),
          },
        ];
      }

      event.waitUntil(notify(options));
    }).catch(() => {}));
};

const findBestClient = clients => {
  const focusedClient = clients.find(client => client.focused);
  const visibleClient = clients.find(client => client.visibilityState === 'visible');

  return focusedClient || visibleClient || clients[0];
};

const expandNotification = notification => {
  const newNotification = { ...notification };

  newNotification.body = newNotification.data.hiddenBody;
  newNotification.image = newNotification.data.hiddenImage;
  newNotification.actions = [];

  return self.registration.showNotification(newNotification.title, newNotification);
};

const openUrl = url =>
  self.clients.matchAll({ type: 'window' }).then(clientList => {
    if (clientList.length !== 0) {
      const webClients = clientList.filter(client => /\/web\//.test(client.url));

      if (webClients.length !== 0) {
        const client       = findBestClient(webClients);
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

const handleNotificationClick = (event) => {
  const reactToNotificationClick = new Promise((resolve, reject) => {
    if (event.action) {
      if (event.action === 'expand') {
        resolve(expandNotification(event.notification));
      } else if (event.action === 'reblog') {
        resolve(); // TODO
      } else if (event.action === 'favourite') {
        resolve(); // TODO
      } else {
        reject(`Unknown action: ${event.action}`);
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
