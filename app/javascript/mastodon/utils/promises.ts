/**
 * Wraps a function that returns a promise so that it only executes once, and subsequent calls return the same promise.
 */
export function onceAsync<TArgs extends unknown[], TResult>(
  callback: (...args: TArgs) => Promise<TResult>,
): (...args: TArgs) => Promise<TResult> {
  let promise: Promise<TResult> | null = null;

  return (...args: TArgs) => {
    promise ??= callback(...args);
    return promise;
  };
}

interface OnceAsyncByArgs<TArgs extends unknown[]> {
  /** Callback to derive a string key from arguments. Defaults to JSON.stringify. */
  keyFromArgs?: (...args: TArgs) => string;
  /** Whether to remove a promise from the cache once it resolves. Defaults to true. */
  deleteOnComplete?: boolean;
  /** Optional callback to log promise changes. */
  log?: (format: string, ...args: unknown[]) => void;
}

/**
 * Wraps an async function so that only one in-flight call exists per argument key.
 * Concurrent calls with the same key share one promise.
 */
export function onceAsyncByArgs<TArgs extends unknown[], TResult>(
  callback: (...args: TArgs) => Promise<TResult>,
  {
    keyFromArgs = (...args) => JSON.stringify(args),
    deleteOnComplete = true,
    log,
  }: OnceAsyncByArgs<TArgs> = {},
): (...args: TArgs) => Promise<TResult> {
  const inFlight = new Map<string, Promise<TResult>>();

  return (...args: TArgs) => {
    const key = keyFromArgs(...args);
    const existingPromise = inFlight.get(key);

    if (existingPromise) {
      log?.(`already have in-flight promise with key ${key}`);
      return existingPromise;
    }

    const promise = callback(...args).finally(() => {
      if (deleteOnComplete) {
        log?.(`deleted completed promise with key ${key}`);
        inFlight.delete(key);
      }
    });
    log?.(`added promise with key ${key}`);
    inFlight.set(key, promise);
    return promise;
  };
}
