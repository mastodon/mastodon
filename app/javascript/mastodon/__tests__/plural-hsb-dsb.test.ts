// app/javascript/mastodon/__tests__/plural-hsb-dsb.test.ts
import '../i18n-plurals';

describe('Intl.PluralRules for Sorbian (hsb/dsb)', () => {
  test('hsb categories', () => {
    const pr = new Intl.PluralRules('hsb');
    expect(pr.select(1)).toBe('one');
    expect(pr.select(2)).toBe('two');
    expect(pr.select(3)).toBe('few');
    expect(pr.select(4)).toBe('few');
    expect(pr.select(5)).toBe('other');
    expect(pr.select(101)).toBe('one'); // 101 % 100 === 1
  });

  test('dsb categories', () => {
    const pr = new Intl.PluralRules('dsb');
    expect(pr.select(1)).toBe('one');
    expect(pr.select(2)).toBe('two');
    expect(pr.select(3)).toBe('few');
    expect(pr.select(5)).toBe('other');
    expect(pr.select(102)).toBe('two'); // 102 % 100 === 2
  });
});
