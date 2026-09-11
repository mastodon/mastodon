import { isUrlWithoutProtocol } from './checks';

describe('isUrlWithoutProtocol', () => {
  test.concurrent.each([
    ['example.com', true],
    ['sub.domain.co.uk', true],
    ['example', false], // No dot
    ['example..com', false], // Consecutive dots
    ['example.com.', false], // Trailing dot
    ['example.c', false], // TLD too short
    ['example.123', false], // Numeric TLDs are not valid
    ['example.com/path', true], // Paths are allowed
    ['example.com?query=string', true], // Query strings are allowed
    ['example.com#fragment', true], // Fragments are allowed
    ['example .com', false], // Spaces are not allowed
    ['example://com', false], // Protocol inside the string is not allowed
    ['example.com^', false], // Invalid characters not allowed
  ])('should return %s for input "%s"', (input, expected) => {
    expect(isUrlWithoutProtocol(input)).toBe(expected);
  });
});
