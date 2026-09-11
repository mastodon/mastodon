import { describe, expect, it } from 'vitest';

import { cyrb32, hashObjectArray } from './hash';

describe('cyrb32', () => {
  const input = 'mastodon';

  it('returns a base-36 lowercase 1-6 character string', () => {
    const hash = cyrb32(input);
    expect(hash).toMatch(/^[0-9a-z]{1,6}$/);
  });

  it('returns the same output for same input and seed', () => {
    const a = cyrb32(input, 1);
    const b = cyrb32(input, 1);

    expect(a).toBe(b);
  });

  it('produces different hashes for different seeds', () => {
    const a = cyrb32(input, 1);
    const b = cyrb32(input, 2);

    expect(a).not.toBe(b);
  });
});

describe('hashObjectArray', () => {
  const input = [
    { name: 'Alice', value: 'Developer' },
    { name: 'Bob', value: 'Designer' },
    { name: 'Alice', value: 'Developer' }, // Duplicate
  ];

  it('returns an array of the same length with unique hash keys', () => {
    const result = hashObjectArray(input);
    expect(result).toHaveLength(input.length);

    const ids = result.map((obj) => obj.id);
    const uniqueIds = new Set(ids);
    expect(uniqueIds.size).toBe(ids.length);
  });

  it('allows custom key names for the hash', () => {
    const result = hashObjectArray(input, 'hashKey');
    expect(result[0]).toHaveProperty('hashKey');
  });
});
