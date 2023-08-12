import { fromJS } from 'immutable';

import { statusContainsOnlyEmoji } from '../status_content';

function makeStatus(content: string) {
  return fromJS({
    search_index: content,
    emojis: [{ shortcode: 'test' }],
  });
}

describe('statusContainsOnlyEmoji', () => {
  const validStatuses = [
    '😃',
    '😇🥲',
    '😃:test:',
    ':test:',
    '😃 :test:',
    '  😃 :test:',
    '😃 :test:   ',
  ];

  const invalidStatuses = [
    '😃 test',
    'test',
    '😃\n😃',
    ':wrong:',
    '😃:wrong:',
    ':wrong: 😃 :test:',
  ];

  test.each(validStatuses)('status %j contains only emoji', (statusText) => {
    expect(statusContainsOnlyEmoji(makeStatus(statusText))).toBe(true);
  });

  test.each(invalidStatuses)(
    'status %j does not contains only emoji',
    (statusText) => {
      expect(statusContainsOnlyEmoji(makeStatus(statusText))).toBe(false);
    },
  );
});
