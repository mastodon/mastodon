import { fromJS } from 'immutable';

import {
  buildComposeSubmitData,
  isScheduledStatusResponse,
} from './submit_payload';

describe('buildComposeSubmitData', () => {
  const media = fromJS([{ id: '123' }, { id: '456' }]);

  const state = fromJS({
    compose: {
      in_reply_to: null,
      sensitive: false,
      poll: null,
      language: 'en',
      quoted_status_id: null,
      quote_policy: 'public',
      scheduled_at: '2026-05-18T10:30',
    },
  });

  test('includes a normalized scheduled_at value for new posts', () => {
    expect(
      buildComposeSubmitData({
        state,
        status: 'Hello future',
        spoilerText: '',
        media,
        mediaAttributes: undefined,
        statusId: null,
        visibility: 'public',
      }).scheduled_at,
    ).toBe(new Date('2026-05-18T10:30').toISOString());
  });

  test('omits scheduled_at when editing a post', () => {
    expect(
      buildComposeSubmitData({
        state,
        status: 'Hello now',
        spoilerText: '',
        media,
        mediaAttributes: [],
        statusId: '42',
        visibility: 'public',
      }),
    ).not.toHaveProperty('scheduled_at');
  });

  test('omits scheduled_at when the compose field is blank', () => {
    expect(
      buildComposeSubmitData({
        state: state.setIn(['compose', 'scheduled_at'], ''),
        status: 'Hello now',
        spoilerText: '',
        media,
        mediaAttributes: undefined,
        statusId: null,
        visibility: 'public',
      }),
    ).not.toHaveProperty('scheduled_at');
  });
});

describe('isScheduledStatusResponse', () => {
  test('recognizes scheduled status API responses', () => {
    expect(
      isScheduledStatusResponse({
        id: '1',
        scheduled_at: '2026-05-18T03:30:00.000Z',
        params: {},
      }),
    ).toBe(true);
  });

  test('does not treat ordinary status responses as scheduled statuses', () => {
    expect(
      isScheduledStatusResponse({
        id: '1',
        uri: 'https://example.com/statuses/1',
        created_at: '2026-05-17T03:30:00.000Z',
      }),
    ).toBe(false);
  });
});
