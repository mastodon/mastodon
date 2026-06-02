/// <reference lib="WebWorker" />
/// <reference types="vite/client" />

import { DAY } from '../utils/time';

const CACHE_NAME_PREFIX = 'mastodon-';
const CACHE_HEADER_TTL = 'x-timestamp';

export async function cacheRoot() {
  const cache = await openWebCache();
  const response = await fetch('/', {
    credentials: 'include',
    redirect: 'manual',
  });
  await cache.put('/', response);
}

export function handleFetch(event: FetchEvent) {
  const url = new URL(event.request.url);

  if (url.pathname === '/auth/sign_out') {
    event.respondWith(handleLogout(event));
  } else if (/intl\/.*\.js$/.test(url.pathname)) {
    event.respondWith(cacheFirst({ event, name: 'locales' }));
  } else if (event.request.destination === 'font') {
    event.respondWith(cacheFirst({ event, name: 'fonts' }));
  } else if (event.request.destination === 'image') {
    event.respondWith(cacheFirst({ event, name: 'images', ttl: DAY * 7 }));
  }
}

async function cacheFirst({
  event,
  name,
  ttl = DAY * 30,
  max = 5,
}: {
  event: FetchEvent;
  name: string;
  ttl?: number;
  max?: number;
}) {
  const cache = await caches.open(`${CACHE_NAME_PREFIX}${name}`);
  const request = event.request;
  const cachedResponse = await cache.match(request);

  // Start expiring cache items while the process continues.
  void expireCachedItems({ name, ttl, max });

  if (cachedResponse) {
    // If we have a cached response, check the TTL header.
    const ttlHeader = Number.parseInt(
      cachedResponse.headers.get(CACHE_HEADER_TTL) ?? '0',
    );

    if (!ttlHeader || ttlHeader + ttl > Date.now()) {
      return cachedResponse;
    }
  }

  const networkResponse = await fetch(request);

  // For opaque responses, the status will be zero so we can't clone them.
  if (networkResponse.status !== 0) {
    // Clone request with a custom header to store timestamp.
    const cloneHeaders = new Headers(networkResponse.headers);
    cloneHeaders.set(CACHE_HEADER_TTL, Date.now().toString());

    const cloneResponse = new Response(networkResponse.clone().body, {
      headers: cloneHeaders,
      status: networkResponse.status,
      statusText: networkResponse.statusText,
    });

    await cache.put(request, cloneResponse);
  }

  return networkResponse;
}

export async function expireCachedItems({
  name,
  ttl = DAY * 30,
  max = 5,
}: {
  name: string;
  ttl?: number;
  max?: number;
}) {
  const cache = await caches.open(`${CACHE_NAME_PREFIX}${name}`);

  const keys = await cache.keys();
  const now = Date.now();
  const validKeys: { key: Request; timestamp: number }[] = [];

  for (const key of keys) {
    const cachedResponse = await cache.match(key);

    if (!cachedResponse) {
      await cache.delete(key);
      continue;
    }

    const timestamp = Number.parseInt(
      cachedResponse.headers.get(CACHE_HEADER_TTL) ?? '0',
    );

    if (!timestamp || timestamp + ttl > now) {
      validKeys.push({ key, timestamp: timestamp || Number.POSITIVE_INFINITY });
      continue;
    }

    await cache.delete(key);
  }

  if (validKeys.length <= max) {
    return;
  }

  const sortedValidKeys = validKeys.toSorted(
    ({ timestamp: a }, { timestamp: b }) => a - b,
  );
  await Promise.all(
    sortedValidKeys
      .slice(0, sortedValidKeys.length - max)
      .map(({ key }) => cache.delete(key)),
  );
}

function openWebCache() {
  return caches.open(`${CACHE_NAME_PREFIX}web`);
}

async function handleLogout(event: FetchEvent) {
  const response = await fetch(event.request);

  if (response.ok || response.type === 'opaqueredirect') {
    const cache = await openWebCache();
    await cache.delete('/');
  }

  return response;
}
