const handlePush = (event) => {
  const { title, options } = event.data.json();

  options.icon = options.icon || '/android-chrome-192x192.png';
  options.timestamp = options.timestamp && new Date(options.timestamp);

  event.waitUntil(self.registration.showNotification(title, options));
};

const handleNotificationClick = (event) => {
  event.notification.close();

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
