import { DAY } from '../utils/time';

import { expireCachedItems, handleFetch } from './caching';

const now = 1_700_000_000_000;

describe('expireCachedItems', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(now);
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.unstubAllGlobals();
  });

  test('deletes expired entries and requests without a cached response', async () => {
    const cache = new MockCache();
    const missingRequest = new Request('https://example.com/missing');

    cache.set('/fresh', now - DAY);
    cache.set('/expired', now - DAY * 31);
    cache.store.set(missingRequest.url, { request: missingRequest });

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(cache),
    });

    await expireCachedItems({ name: 'images', ttl: DAY * 30, max: 5 });

    expect(Array.from(cache.store.keys())).toEqual([
      'https://example.com/fresh',
    ]);
  });

  test('trims the oldest valid entries when the cache exceeds max size', async () => {
    const cache = new MockCache();

    cache.set('/oldest', now - DAY * 3);
    cache.set('/older', now - DAY * 2);
    cache.set('/newest', now - DAY);

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(cache),
    });

    await expireCachedItems({ name: 'images', ttl: DAY * 30, max: 2 });

    expect(Array.from(cache.store.keys())).toEqual([
      'https://example.com/older',
      'https://example.com/newest',
    ]);
  });

  test('keeps entries without a timestamp header over timestamped entries', async () => {
    const cache = new MockCache();
    const untimestampedRequest = new Request('https://example.com/no-header');

    cache.store.set(untimestampedRequest.url, {
      request: untimestampedRequest,
      response: createResponse(),
    });
    cache.set('/older', now - DAY * 2);
    cache.set('/newer', now - DAY);

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(cache),
    });

    await expireCachedItems({ name: 'images', ttl: DAY * 30, max: 2 });

    expect(Array.from(cache.store.keys())).toEqual([
      'https://example.com/no-header',
      'https://example.com/newer',
    ]);
  });
});

describe('handleFetch', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(now);
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.unstubAllGlobals();
  });

  test('serves cached images without hitting the network while the TTL is valid', async () => {
    const imageCache = new MockCache();
    const request = createRequest('/test.png', 'image');
    const cachedResponse = createResponse(now - DAY);

    imageCache.store.set(request.url, { request, response: cachedResponse });

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(imageCache),
    });

    const fetch = vi.fn();
    vi.stubGlobal('fetch', fetch);

    const { event, respondWith } = createFetchEvent(request);

    handleFetch(event);

    await expect(respondWith()).resolves.toBe(cachedResponse);
    expect(fetch).not.toHaveBeenCalled();
  });

  test('fetches stale cached images from the network and stores a refreshed response', async () => {
    const imageCache = new MockCache();
    const request = createRequest('/stale.png', 'image');
    const networkResponse = new Response('fresh', {
      headers: { 'content-type': 'image/png' },
      status: 200,
      statusText: 'OK',
    });
    const putSpy = vi.spyOn(imageCache, 'put');

    imageCache.store.set(request.url, {
      request,
      response: createResponse(now - DAY * 8),
    });

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(imageCache),
    });

    const fetch = vi.fn().mockResolvedValue(networkResponse);
    vi.stubGlobal('fetch', fetch);

    const { event, respondWith } = createFetchEvent(request);

    handleFetch(event);

    await expect(respondWith()).resolves.toBe(networkResponse);
    expect(fetch).toHaveBeenCalledWith(request);
    expect(putSpy).toHaveBeenCalledWith(request, expect.any(Response));
    expect(
      imageCache.store.get(request.url)?.response?.headers.get('x-timestamp'),
    ).toBe(now.toString());
  });

  test('does not cache opaque image responses with status zero', async () => {
    const imageCache = new MockCache();
    const request = createRequest('/opaque.png', 'image');
    const opaqueResponse = Response.error();
    const putSpy = vi.spyOn(imageCache, 'put');

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(imageCache),
    });

    const fetch = vi.fn().mockResolvedValue(opaqueResponse);
    vi.stubGlobal('fetch', fetch);

    const { event, respondWith } = createFetchEvent(request);

    handleFetch(event);

    await expect(respondWith()).resolves.toBe(opaqueResponse);
    expect(fetch).toHaveBeenCalledWith(request);
    expect(putSpy).not.toHaveBeenCalled();
    expect(imageCache.store.size).toBe(0);
  });

  test.each([
    ['/intl/en.js', '', 'mastodon-locales'],
    ['/fonts/mastodon.woff2', 'font', 'mastodon-fonts'],
  ])(
    'routes %s requests through %s',
    async (pathname, destination, cacheName) => {
      const cache = new MockCache();
      const request = createRequest(pathname, destination);
      const networkResponse = new Response('asset', { status: 200 });
      const open = vi.fn().mockImplementation((name: string) => {
        expect(name).toBe(cacheName);
        return Promise.resolve(cache);
      });

      vi.stubGlobal('caches', { open });

      const fetch = vi.fn().mockResolvedValue(networkResponse);
      vi.stubGlobal('fetch', fetch);

      const { event, respondWith } = createFetchEvent(request);

      handleFetch(event);

      await expect(respondWith()).resolves.toBe(networkResponse);
      expect(fetch).toHaveBeenCalledWith(request);
      expect(open).toHaveBeenCalledWith(cacheName);
    },
  );

  test('clears the root cache after a successful logout request', async () => {
    const webCache = new MockCache();
    const deleteSpy = vi.spyOn(webCache, 'delete');

    vi.stubGlobal('caches', {
      open: vi.fn().mockImplementation((name: string) => {
        expect(name).toBe('mastodon-web');
        return Promise.resolve(webCache);
      }),
    });

    const fetch = vi
      .fn()
      .mockResolvedValue(new Response(null, { status: 200 }));
    vi.stubGlobal('fetch', fetch);

    const { event, respondWith } = createFetchEvent(
      createRequest('/auth/sign_out'),
    );

    handleFetch(event);

    await expect(respondWith()).resolves.toBeInstanceOf(Response);
    expect(deleteSpy).toHaveBeenCalledWith('/');
  });

  test('does not clear the root cache after a failed logout request', async () => {
    const webCache = new MockCache();
    const deleteSpy = vi.spyOn(webCache, 'delete');

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(webCache),
    });

    const fetch = vi
      .fn()
      .mockResolvedValue(
        new Response(null, { status: 500, statusText: 'Error' }),
      );
    vi.stubGlobal('fetch', fetch);

    const { event, respondWith } = createFetchEvent(
      createRequest('/auth/sign_out'),
    );

    handleFetch(event);

    await expect(respondWith()).resolves.toBeInstanceOf(Response);
    expect(deleteSpy).not.toHaveBeenCalled();
  });

  test('clears the root cache for opaqueredirect logout responses', async () => {
    const webCache = new MockCache();
    const deleteSpy = vi.spyOn(webCache, 'delete');
    const opaqueRedirectResponse = {
      ok: false,
      type: 'opaqueredirect',
    } as Response;

    vi.stubGlobal('caches', {
      open: vi.fn().mockResolvedValue(webCache),
    });

    const fetch = vi.fn().mockResolvedValue(opaqueRedirectResponse);
    vi.stubGlobal('fetch', fetch);

    const { event, respondWith } = createFetchEvent(
      createRequest('/auth/sign_out'),
    );

    handleFetch(event);

    await expect(respondWith()).resolves.toBe(opaqueRedirectResponse);
    expect(deleteSpy).toHaveBeenCalledWith('/');
  });

  test('ignores requests that are not handled by the service worker cache', () => {
    const { event, respondWith, respondWithMock } = createFetchEvent(
      createRequest('/api/v1/timelines/home'),
    );

    handleFetch(event);

    expect(respondWithMock).not.toHaveBeenCalled();
    expect(respondWith()).toBeUndefined();
  });
});

interface CacheEntry {
  request: Request;
  response?: Response;
}

class MockCache implements Cache {
  public readonly store = new Map<string, CacheEntry>();

  private normalizeRequest(request: RequestInfo | URL) {
    if (request instanceof Request) {
      return request.url;
    }

    return request.toString();
  }

  add(): Promise<void> {
    return Promise.reject(new Error('Not implemented'));
  }

  addAll(): Promise<void> {
    return Promise.reject(new Error('Not implemented'));
  }

  delete(request: RequestInfo | URL): Promise<boolean> {
    return Promise.resolve(this.store.delete(this.normalizeRequest(request)));
  }

  keys(): Promise<readonly Request[]> {
    return Promise.resolve(
      Array.from(this.store.values(), ({ request }) => request),
    );
  }

  match(request: RequestInfo | URL): Promise<Response | undefined> {
    return Promise.resolve(
      this.store.get(this.normalizeRequest(request))?.response,
    );
  }

  matchAll(): Promise<readonly Response[]> {
    return Promise.reject(new Error('Not implemented'));
  }

  put(request: RequestInfo | URL, response: Response): Promise<void> {
    const normalizedRequest =
      request instanceof Request ? request : new Request(request);

    this.store.set(this.normalizeRequest(normalizedRequest), {
      request: normalizedRequest,
      response,
    });

    return Promise.resolve();
  }

  set(pathname: string, timestamp?: number) {
    const request = new Request(`https://example.com${pathname}`);

    this.store.set(request.url, {
      request,
      response: createResponse(timestamp),
    });

    return request;
  }
}

function createResponse(timestamp?: number) {
  const headers = new Headers();

  if (timestamp !== undefined) {
    headers.set('x-timestamp', timestamp.toString());
  }

  return new Response('body', { headers });
}

function createRequest(pathname: string, destination = '') {
  const request = new Request(`https://example.com${pathname}`);

  Object.defineProperty(request, 'destination', {
    value: destination,
    configurable: true,
  });

  return request;
}

function createFetchEvent(request: Request) {
  let responsePromise: Promise<Response> | undefined;
  const respondWith = vi.fn((response: Response | Promise<Response>) => {
    responsePromise = Promise.resolve(response);
  });

  return {
    event: {
      request,
      respondWith,
    } as unknown as FetchEvent,
    respondWith: () => responsePromise,
    respondWithMock: respondWith,
  };
}
