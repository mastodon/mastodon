import { createCache } from '../cache';

describe('createCache', () => {
  it('returns expected methods', () => {
    const actual = createCache();
    expect(actual).toBeTypeOf('object');
    expect(actual).toHaveProperty('get');
    expect(actual).toHaveProperty('has');
    expect(actual).toHaveProperty('delete');
    expect(actual).toHaveProperty('set');
  });

  it('caches values provided to it', () => {
    const cache = createCache();
    cache.set('test', 'result');
    expect(cache.get('test')).toBe('result');
  });

  it('has returns expected values', () => {
    const cache = createCache();
    cache.set('test', 'result');
    expect(cache.has('test')).toBeTruthy();
    expect(cache.has('not found')).toBeFalsy();
  });

  it('updates a value if keys are the same', () => {
    const cache = createCache();
    cache.set('test1', 1);
    cache.set('test1', 2);
    expect(cache.get('test1')).toBe(2);
  });

  it('delete removes an item', () => {
    const cache = createCache();
    cache.set('test', 'result');
    expect(cache.has('test')).toBeTruthy();
    cache.delete('test');
    expect(cache.has('test')).toBeFalsy();
    expect(cache.get('test')).toBeUndefined();
  });

  it('removes oldest item cached if it exceeds a set size', () => {
    const cache = createCache(1);
    cache.set('test1', 1);
    cache.set('test2', 2);
    expect(cache.get('test1')).toBeUndefined();
    expect(cache.get('test2')).toBe(2);
  });

  it('retrieving a value bumps up last access', () => {
    const cache = createCache(2);
    cache.set('test1', 1);
    cache.set('test2', 2);
    expect(cache.get('test1')).toBe(1);
    cache.set('test3', 3);
    expect(cache.get('test1')).toBe(1);
    expect(cache.get('test2')).toBeUndefined();
    expect(cache.get('test3')).toBe(3);
  });
});
