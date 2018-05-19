import './web_push_notifications';

function openCache() {
  return caches.open('mastodon-web');
}

function fetchRoot() {
  return fetch('/', { credentials: 'include' });
}

// Cause a new version of a registered Service Worker to replace an existing one
// that is already installed, and replace the currently active worker on open pages.
self.addEventListener('install', function(event) {
  event.waitUntil(Promise.all([openCache(), fetchRoot()]).then(([cache, root]) => cache.put('/', root)));
});
self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});
self.addEventListener('fetch', function(event) {
  const url = new URL(event.request.url);

  if (url.pathname.startsWith('/web/')) {
    const asyncResponse = fetchRoot();
    const asyncCache = openCache();

    event.respondWith(asyncResponse.then(async response => {
      if (response.ok) {
        const cache = await asyncCache;
        await cache.put('/', response);
        return response.clone();
      }

      throw null;
    }).catch(() => caches.match('/')));
  } else if (url.pathname === '/auth/sign_out') {
    const asyncResponse = fetch(event.request);
    const asyncCache = openCache();

    event.respondWith(asyncResponse.then(async response => {
      if (response.ok || response.type === 'opaqueredirect') {
        const cache = await asyncCache;
        await cache.delete('/');
      }

      return response;
    }));
  }
});
