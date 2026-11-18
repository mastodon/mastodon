import { dismissAlert, showAlert } from 'mastodon/actions/alerts';

import { alertsReducer } from './alerts';

const alert = { title: 'Error', message: 'An error occurred' };

describe('alertsReducer', () => {
  it('deduplicates alerts with the same title and message', () => {
    const state = alertsReducer([{ ...alert, key: -1 }], showAlert(alert));

    expect(state).toEqual([{ ...alert, key: -1 }]);
  });

  it('does not combine nonmatching alerts', () => {
    const state = alertsReducer(
      [{ ...alert, key: -1 }],
      showAlert({ title: 'Another error', message: 'Something else happened' }),
    );

    expect(state).toHaveLength(2);
  });

  it('starts a fresh alert after dismissal', () => {
    const dismissed = alertsReducer(
      [{ ...alert, key: -1 }],
      dismissAlert({ key: -1 }),
    );
    const state = alertsReducer(dismissed, showAlert(alert));

    expect(state).toHaveLength(1);
    expect(state[0]?.key).not.toBe(-1);
  });
});
