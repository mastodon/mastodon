/* global describe, expect, test */

import { normalizeStatus, searchTextFromRawStatus } from './normalizer';

const makeStatus = (overrides = {}) => ({
  account: { id: '1' },
  content: '<p>Actual quote text</p><p class="quote-inline"><a href="https://example.com/@quoted/1">RE: https://example.com/@quoted/1</a></p>',
  media_attachments: [],
  sensitive: false,
  spoiler_text: '',
  uri: 'https://example.com/@author/1',
  url: 'https://example.com/@author/1',
  ...overrides,
});

describe('searchTextFromRawStatus', () => {
  test('strips quote fallback text from search content', () => {
    expect(searchTextFromRawStatus(makeStatus())).toBe('Actual quote text');
  });
});

describe('normalizeStatus', () => {
  test('strips quote fallback text from search_index when quote metadata is unavailable', () => {
    expect(normalizeStatus(makeStatus(), null, {}).search_index).toBe('Actual quote text');
  });
});