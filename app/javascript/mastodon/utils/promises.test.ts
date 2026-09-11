import { onceAsync, onceAsyncByArgs } from './promises';

describe('onceAsync', () => {
  test('calls async callback once for concurrent calls', async () => {
    let callCount = 0;
    let resolveValue!: (value: string) => void;

    const wrapped = onceAsync(async () => {
      callCount += 1;
      return new Promise<string>((resolve) => {
        resolveValue = resolve;
      });
    });

    const first = wrapped();
    const second = wrapped();

    expect(callCount).toBe(1);
    expect(first).toBe(second);

    resolveValue('ok');

    await expect(first).resolves.toBe('ok');
    await expect(second).resolves.toBe('ok');
  });

  test('returns cached response for later calls without re-running callback', async () => {
    let callCount = 0;
    const wrapped = onceAsync(() => {
      callCount += 1;
      return Promise.resolve('cached');
    });

    await expect(wrapped()).resolves.toBe('cached');
    await expect(wrapped()).resolves.toBe('cached');

    expect(callCount).toBe(1);
  });

  test('keeps the same rejection promise and does not re-run callback', async () => {
    let callCount = 0;
    const error = new Error('boom');

    const wrapped = onceAsync(() => {
      callCount += 1;
      return Promise.reject(error);
    });

    await expect(wrapped()).rejects.toThrow('boom');
    await expect(wrapped()).rejects.toThrow('boom');

    expect(callCount).toBe(1);
  });
});

describe('onceAsyncByArgs', () => {
  test('shares one in-flight callback for the same argument key', async () => {
    let callCount = 0;
    let resolveValue!: (value: string) => void;

    const wrapped = onceAsyncByArgs((arg: string, bool: boolean) => {
      callCount += 1;
      return new Promise<string>((resolve) => {
        resolveValue = (value: string) => {
          resolve(`${arg}:${bool}:${value}`);
        };
      });
    });

    const first = wrapped('test', true);
    const second = wrapped('test', true);

    expect(callCount).toBe(1);
    expect(first).toBe(second);

    resolveValue('done');

    await expect(first).resolves.toBe('test:true:done');
    await expect(second).resolves.toBe('test:true:done');
  });

  test('runs separate callbacks for different argument keys', async () => {
    let callCount = 0;

    const wrapped = onceAsyncByArgs((arg: string, bool: boolean) => {
      callCount += 1;
      return Promise.resolve(`${arg}:${bool}`);
    });

    await expect(wrapped('test', false)).resolves.toBe('test:false');
    await expect(wrapped('test', true)).resolves.toBe('test:true');

    expect(callCount).toBe(2);
  });

  test('allows the same key to run again after previous promise settles', async () => {
    let callCount = 0;

    const wrapped = onceAsyncByArgs((arg: string) => {
      callCount += 1;
      return Promise.resolve(arg);
    });

    await expect(wrapped('test')).resolves.toBe('test');
    await expect(wrapped('test')).resolves.toBe('test');

    expect(callCount).toBe(2);
  });

  test('returns resolved promise again if deleteOnComplete is false', async () => {
    let callCount = 0;

    const wrapped = onceAsyncByArgs(
      (arg: string) => {
        callCount += 1;
        return Promise.resolve(arg);
      },
      { deleteOnComplete: false },
    );

    const first = wrapped('test');
    await expect(first).resolves.toBe('test');

    const second = wrapped('test');
    await expect(second).resolves.toBe('test');

    expect(first).toBe(second);
    expect(callCount).toBe(1);
  });

  test('calls log function when provided', async () => {
    let resolveValue!: (value: string) => void;
    const log = vi.fn<(format: string, ...args: unknown[]) => void>();

    const wrapped = onceAsyncByArgs(
      (arg: string) =>
        new Promise<string>((resolve) => {
          resolveValue = (value: string) => {
            resolve(`${arg}:${value}`);
          };
        }),
      { log },
    );

    const first = wrapped('test');
    const second = wrapped('test');
    expect(first).toBe(second);

    resolveValue('done');
    await expect(first).resolves.toBe('test:done');

    expect(log).toHaveBeenCalledWith(
      expect.stringContaining('added promise with key'),
    );
    expect(log).toHaveBeenCalledWith(
      expect.stringContaining('already have in-flight promise with key'),
    );
    expect(log).toHaveBeenCalledWith(
      expect.stringContaining('deleted completed promise with key'),
    );
  });

  test('re-runs callback for same key after rejection with default deleteOnComplete', async () => {
    let callCount = 0;
    const wrapped = onceAsyncByArgs((arg: string) => {
      callCount += 1;
      return Promise.reject(new Error(`boom:${arg}`));
    });

    await expect(wrapped('test')).rejects.toThrow('boom');
    await expect(wrapped('test')).rejects.toThrow('boom');

    expect(callCount).toBe(2);
  });

  test('uses keyFromArgs to dedupe by custom key', async () => {
    let callCount = 0;
    let resolveValue!: (value: string) => void;

    const wrapped = onceAsyncByArgs(
      ({ id }: { id: string; payload: string }) => {
        callCount += 1;
        return new Promise<string>((resolve) => {
          resolveValue = (value: string) => {
            resolve(`${id}:${value}`);
          };
        });
      },
      {
        keyFromArgs: ({ id }) => id,
      },
    );

    const first = wrapped({ id: '1', payload: 'a' });
    const second = wrapped({ id: '1', payload: 'b' });

    expect(first).toBe(second);
    expect(callCount).toBe(1);

    resolveValue('ok');
    await expect(first).resolves.toBe('1:ok');
  });
});
