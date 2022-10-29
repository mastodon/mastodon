import { ExpirationPlugin } from 'workbox-expiration';
import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { CacheFirst } from 'workbox-strategies';
import { handleNotificationClick, handlePush } from './web_push_notifications';

const CACHE_NAME_PREFIX = 'mastodon-';

function openWebCache() {
  return caches.open(`${CACHE_NAME_PREFIX}web`);
}

function fetchRoot() {
  return fetch('/', { credentials: 'include', redirect: 'manual' });
}

precacheAndRoute(self.__WB_MANIFEST);

registerRoute(
  /locale_.*\.js$/,
  new CacheFirst({
    cacheName: `${CACHE_NAME_PREFIX}locales`,
    plugins: [
      new ExpirationPlugin({
        maxAgeSeconds: 30 * 24 * 60 * 60, // 1 month
        maxEntries: 5,
      }),
    ],
  }),
);

registerRoute(
  ({ request }) => request.destination === 'font',
  new CacheFirst({
    cacheName: `${CACHE_NAME_PREFIX}fonts`,
    plugins: [
      new ExpirationPlugin({
        maxAgeSeconds: 30 * 24 * 60 * 60, // 1 month
        maxEntries: 5,
      }),
    ],
  }),
);

registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: `m${CACHE_NAME_PREFIX}media`,
    plugins: [
      new ExpirationPlugin({
        maxAgeSeconds: 7 * 24 * 60 * 60, // 1 week
        maxEntries: 256,
      }),
    ],
  }),
);

// Cause a new version of a registered Service Worker to replace an existing one
// that is already installed, and replace the currently active worker on open pages.
self.addEventListener('install', function(event) {
  event.waitUntil(Promise.all([openWebCache(), fetchRoot()]).then(([cache, root]) => cache.put('/', root)));
});

self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(event) {
  const url = new URL(event.request.url);

  if (url.pathname === '/auth/sign_out') {
    const asyncResponse = fetch(event.request);
    const asyncCache = openWebCache();

    event.respondWith(asyncResponse.then(response => {
      if (response.ok || response.type === 'opaqueredirect') {
        return Promise.all([
          asyncCache.then(cache => cache.delete('/')),
          indexedDB.deleteDatabase('mastodon'),
        ]).then(() => response);
      }

      return response;
    }));
  }
});

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
