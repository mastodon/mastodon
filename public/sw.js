const handlePush = (event) => {
  console.log('push', event.data.json());
  const { title, options } = event.data.json();

  options.icon = options.icon || '/android-chrome-192x192.png';
  options.timestamp = options.timestamp && new Date(options.timestamp);

  event.waitUntil(self.registration.showNotification(title, options));
};

const handleNotificationClick = (event) => {
  console.log('click', event);
  event.notification.close();
  event.waitUntil(clients.openWindow(event.notification.data.url));
};

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
