import './web_push_notifications';

function fetchRoot() {
  return fetch('/', { credentials: 'include' });
}

// Cause a new version of a registered Service Worker to replace an existing one
// that is already installed, and replace the currently active worker on open pages.
self.addEventListener('install', function(event) {
  const promises = Promise.all([caches.open('mastodon-web'), fetchRoot()]);
  const asyncAdd = promises.then(([cache, root]) => cache.put('/', root));

  event.waitUntil(asyncAdd);
});
self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});
self.addEventListener('fetch', function(event) {
  const url = new URL(event.request.url);

  if (url.pathname.startsWith('/web/')) {
    event.respondWith(fetchRoot().then(response => {
      if (response.ok) {
        return response;
      }

      throw null;
    }).catch(() => caches.match('/')));
  }
});
