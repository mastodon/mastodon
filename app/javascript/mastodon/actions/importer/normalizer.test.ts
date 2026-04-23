import type { ApiStatusJSON } from '@/mastodon/api_types/statuses';
import { statusFactory } from '@/testing/factories';

import { normalizeStatus, searchTextFromRawStatus } from './normalizer';

const quoteContent =
  '<p>Actual quote text</p><p class="quote-inline"><a href="https://example.com/@quoted/1">RE: https://example.com/@quoted/1</a></p>';

const makeStatus = (overrides: Partial<ApiStatusJSON> = {}) =>
  statusFactory({
    content: quoteContent,
    ...overrides,
  });

describe('searchTextFromRawStatus', () => {
  test('strips quote fallback text from search content', () => {
    expect(searchTextFromRawStatus(makeStatus())).toBe('Actual quote text');
  });
});

describe('normalizeStatus', () => {
  test('strips quote fallback text from search_index when quote metadata is unavailable', () => {
    expect(normalizeStatus(makeStatus(), null, {}).search_index).toBe(
      'Actual quote text',
    );
  });
});