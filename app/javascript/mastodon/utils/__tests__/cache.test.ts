import { createLimitedCache } from '../cache';

describe('createCache', () => {
  test('returns expected methods', () => {
    const actual = createLimitedCache();
    expect(actual).toBeTypeOf('object');
    expect(actual).toHaveProperty('get');
    expect(actual).toHaveProperty('has');
    expect(actual).toHaveProperty('delete');
    expect(actual).toHaveProperty('set');
  });

  test('caches values provided to it', () => {
    const cache = createLimitedCache();
    cache.set('test', 'result');
    expect(cache.get('test')).toBe('result');
  });

  test('has returns expected values', () => {
    const cache = createLimitedCache();
    cache.set('test', 'result');
    expect(cache.has('test')).toBeTruthy();
    expect(cache.has('not found')).toBeFalsy();
  });

  test('updates a value if keys are the same', () => {
    const cache = createLimitedCache();
    cache.set('test1', 1);
    cache.set('test1', 2);
    expect(cache.get('test1')).toBe(2);
  });

  test('delete removes an item', () => {
    const cache = createLimitedCache();
    cache.set('test', 'result');
    expect(cache.has('test')).toBeTruthy();
    cache.delete('test');
    expect(cache.has('test')).toBeFalsy();
    expect(cache.get('test')).toBeUndefined();
  });

  test('removes oldest item cached if it exceeds a set size', () => {
    const cache = createLimitedCache({ maxSize: 1 });
    cache.set('test1', 1);
    cache.set('test2', 2);
    expect(cache.get('test1')).toBeUndefined();
    expect(cache.get('test2')).toBe(2);
  });

  test('retrieving a value bumps up last access', () => {
    const cache = createLimitedCache({ maxSize: 2 });
    cache.set('test1', 1);
    cache.set('test2', 2);
    expect(cache.get('test1')).toBe(1);
    cache.set('test3', 3);
    expect(cache.get('test1')).toBe(1);
    expect(cache.get('test2')).toBeUndefined();
    expect(cache.get('test3')).toBe(3);
  });

  test('logs when cache is added to and removed', () => {
    const log = vi.fn();
    const cache = createLimitedCache({ maxSize: 1, log });
    cache.set('test1', 1);
    expect(log).toHaveBeenLastCalledWith(
      'Added %s to cache, now size %d',
      'test1',
      1,
    );
    cache.set('test2', 1);
    expect(log).toHaveBeenLastCalledWith(
      'Added %s and deleted %s from cache, now size %d',
      'test2',
      'test1',
      1,
    );
  });
});
