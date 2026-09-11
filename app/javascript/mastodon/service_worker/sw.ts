/// <reference lib="WebWorker" />
/// <reference types="vite/client" />

import { cacheRoot, handleFetch } from './caching';
import { handleNotificationClick, handlePush } from './web_push_notifications';

declare const self: ServiceWorkerGlobalScope;

// Cause a new version of a registered Service Worker to replace an existing one
// that is already installed, and replace the currently active worker on open pages.
self.addEventListener('install', (event) => {
  event.waitUntil(cacheRoot());
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', handleFetch);

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
