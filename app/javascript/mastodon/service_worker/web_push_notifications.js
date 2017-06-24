const handlePush = (event) => {
  const { title, options } = event.data.json();

  options.icon = options.icon || '/android-chrome-192x192.png';
  options.timestamp = options.timestamp && new Date(options.timestamp);

  event.waitUntil(self.registration.showNotification(title, options));
};

const handleNotificationClick = (event) => {
  event.notification.close();

  // If there is an open Mastodon tab, focus it, otherwise open a new tab.
  // Might be better to always open a new tab, since it will always be relevant
  // to the content of the notification (will be a deep link).
  const reactToNotificationClick = self.clients.matchAll().then(clientList => {
    if (clientList.length !== 0) {
      clientList[0].focus();
    } else {
      self.clients.openWindow(event.notification.data.url);
    }
  });

  event.waitUntil(reactToNotificationClick);
};

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
