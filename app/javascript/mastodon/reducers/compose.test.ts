import { composeReducer } from './compose';
import { COMPOSE_REDRAFT_SCHEDULED_STATUS } from '../actions/compose';

describe('composeReducer scheduled status redraft', () => {
  test('loads a scheduled post into the composer', () => {
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
    expect((state.getIn(['poll', 'options']) as { toJS: () => string[] }).toJS()).toEqual([
      'One',
      'Two',
      '',
    ]);
  });
});
