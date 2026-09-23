import { isStandaloneComposePath } from './compose_path';

describe('isStandaloneComposePath', () => {
  test('returns true for /publish', () => {
    expect(isStandaloneComposePath('/publish')).toBe(true);
  });

  test('returns true for /statuses/new', () => {
    expect(isStandaloneComposePath('/statuses/new')).toBe(true);
  });

  test('returns true for /deck/publish', () => {
    expect(isStandaloneComposePath('/deck/publish')).toBe(true);
  });

  test('returns true for /deck/statuses/new', () => {
    expect(isStandaloneComposePath('/deck/statuses/new')).toBe(true);
  });

  test('returns false for /deck/home', () => {
    expect(isStandaloneComposePath('/deck/home')).toBe(false);
  });

  test('returns false for /home', () => {
    expect(isStandaloneComposePath('/home')).toBe(false);
  });

  test('returns false for /deck', () => {
    expect(isStandaloneComposePath('/deck')).toBe(false);
  });

  test('returns false for /deck/publish/extra', () => {
    expect(isStandaloneComposePath('/deck/publish/extra')).toBe(false);
  });
});
