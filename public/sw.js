const handlePush = (event) => {
  const { title, body, icon = '/android-chrome-192x192.png' } = event.data.json();

  const options = { body, icon };

  event.waitUntil(self.registration.showNotification(title, options));
};

self.addEventListener('push', handlePush);
