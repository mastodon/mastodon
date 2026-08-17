import { inputToHashtag } from './hashtags';

describe('inputToHashtag', () => {
  test.concurrent.each([
    ['', ''],
    // Prepend or keep hashtag
    ['mastodon', '#mastodon'],
    ['#mastodon', '#mastodon'],
    // Preserve trailing whitespace
    ['mastodon  ', '#mastodon  '],
    ['   ', '#   '],
    // Collapse whitespace & capitalise first character
    ['cats of mastodon', '#catsOfMastodon'],
    ['x y z', '#xYZ'],
    ['   mastodon', '#mastodon'],
    // Preserve initial casing
    ['Log in', '#LogIn'],
    ['#NaturePhotography', '#NaturePhotography'],
    // Normalise hash symbol variant
    ['＃nature', '#nature'],
    ['＃Nature Photography', '#NaturePhotography'],
    // Allow special characters
    ['hello-world', '#hello-world'],
    ['hello,world', '#hello,world'],
  ])('for input "%s", return "%s"', (input, expected) => {
    expect(inputToHashtag(input)).toBe(expected);
  });
});
