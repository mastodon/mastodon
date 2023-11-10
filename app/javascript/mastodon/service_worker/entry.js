import { handleNotificationClick, handlePush } from './web_push_notifications';

self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(event) {
  const url = new URL(event.request.url);

  if (url.pathname === '/auth/sign_out') {
    const asyncResponse = fetch(event.request);

    event.respondWith(asyncResponse.then(response => {
      if (response.ok || response.type === 'opaqueredirect') {
        return indexedDB.deleteDatabase('mastodon').then(() => response);
      }

      return response;
    }));
  }
});

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
