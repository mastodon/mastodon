import type { List as ImmutableList } from 'immutable';

import { composeReducer } from './compose';
import {
  COMPOSE_SCHEDULE_CHANGE,
  COMPOSE_REDRAFT_SCHEDULED_STATUS,
} from '../actions/compose';

describe('composeReducer scheduled status', () => {
  test('updates scheduled_at on COMPOSE_SCHEDULE_CHANGE', () => {
    const state = composeReducer(undefined, {
      type: COMPOSE_SCHEDULE_CHANGE,
      scheduledAt: '2025-01-02T08:30',
    });

    expect(state.get('scheduled_at')).toBe('2025-01-02T08:30');
    expect(state.get('idempotencyKey')).not.toBeNull();
  });

  test('loads a scheduled post into the composer on COMPOSE_REDRAFT_SCHEDULED_STATUS', () => {
    const state = composeReducer(undefined, {
      type: COMPOSE_REDRAFT_SCHEDULED_STATUS,
      scheduledStatus: {
        scheduled_at: new Date(2025, 0, 2, 8, 30).toISOString(),
        media_attachments: [{ id: '123' }],
        params: {
          text: 'Scheduled hello',
          spoiler_text: 'CW',
          visibility: 'private',
          sensitive: true,
          language: 'en',
          in_reply_to_id: '42',
          quoted_status_id: '99',
          quote_approval_policy: 'followers',
          poll: {
            options: ['One', 'Two'],
            multiple: false,
            expires_in: 3600,
          },
        },
      },
      maxOptions: 4,
    });

    expect(state.get('text')).toBe('Scheduled hello');
    expect(state.get('scheduled_at')).toBe('2025-01-02T08:30');
    expect(state.get('privacy')).toBe('private');
    expect(state.get('spoiler')).toBe(true);
    expect(state.get('spoiler_text')).toBe('CW');
    expect(state.get('sensitive')).toBe(true);
    expect(state.get('in_reply_to')).toBe('42');
    expect(state.get('quoted_status_id')).toBe('99');
    expect(state.get('quote_policy')).toBe('followers');

    const pollOptions = state.getIn(['poll', 'options']) as ImmutableList<string>;
    expect(pollOptions.toJS()).toEqual(['One', 'Two', '']);
  });
});
