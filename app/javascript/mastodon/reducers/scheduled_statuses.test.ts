import type { List as ImmutableList } from 'immutable';

import scheduledStatuses from './scheduled_statuses';
import {
  SCHEDULED_STATUSES_FETCH_REQUEST,
  SCHEDULED_STATUSES_FETCH_SUCCESS,
  SCHEDULED_STATUSES_EXPAND_SUCCESS,
  SCHEDULED_STATUS_UPDATE_SUCCESS,
  SCHEDULED_STATUS_DELETE_SUCCESS,
} from '../actions/scheduled_statuses';
import { COMPOSE_SUBMIT_SUCCESS } from '../actions/compose';

describe('scheduledStatuses reducer', () => {
  test('sets isLoading on fetch request', () => {
    const state = scheduledStatuses(undefined, {
      type: SCHEDULED_STATUSES_FETCH_REQUEST,
    });

    expect(state.get('isLoading')).toBe(true);
  });

  test('normalizes statuses on fetch success', () => {
    const statuses = [
      { id: '1', scheduled_at: '2025-01-02T10:00:00.000Z', params: { text: 'one' } },
      { id: '2', scheduled_at: '2025-01-02T11:00:00.000Z', params: { text: 'two' } },
    ];
    const state = scheduledStatuses(undefined, {
      type: SCHEDULED_STATUSES_FETCH_SUCCESS,
      statuses,
      next: 'https://example.com/api/v1/scheduled_statuses?max_id=2',
    });

    expect(state.get('loaded')).toBe(true);
    expect(state.get('isLoading')).toBe(false);
    expect((state.get('items') as ImmutableList<unknown>).size).toBe(2);
    expect(state.get('next')).toBe('https://example.com/api/v1/scheduled_statuses?max_id=2');
  });

  test('appends unique statuses on expand success', () => {
    const initial = scheduledStatuses(undefined, {
      type: SCHEDULED_STATUSES_FETCH_SUCCESS,
      statuses: [{ id: '1', scheduled_at: '2025-01-02T10:00:00.000Z', params: { text: 'one' } }],
      next: 'next-page',
    });

    const state = scheduledStatuses(initial, {
      type: SCHEDULED_STATUSES_EXPAND_SUCCESS,
      statuses: [
        { id: '1', scheduled_at: '2025-01-02T10:00:00.000Z', params: { text: 'one' } },
        { id: '2', scheduled_at: '2025-01-02T11:00:00.000Z', params: { text: 'two' } },
      ],
      next: null,
    });

    expect((state.get('items') as ImmutableList<unknown>).size).toBe(2);
    expect(state.get('next')).toBeNull();
  });

  test('replaces status on update success', () => {
    const initial = scheduledStatuses(undefined, {
      type: SCHEDULED_STATUSES_FETCH_SUCCESS,
      statuses: [{ id: '1', scheduled_at: '2025-01-02T10:00:00.000Z', params: { text: 'original' } }],
      next: null,
    });

    const state = scheduledStatuses(initial, {
      type: SCHEDULED_STATUS_UPDATE_SUCCESS,
      status: { id: '1', scheduled_at: '2025-01-02T12:00:00.000Z', params: { text: 'updated' } },
    });

    expect(state.getIn(['items', 0, 'params', 'text'])).toBe('updated');
  });

  test('removes status on delete success', () => {
    const initial = scheduledStatuses(undefined, {
      type: SCHEDULED_STATUSES_FETCH_SUCCESS,
      statuses: [{ id: '1', scheduled_at: '2025-01-02T10:00:00.000Z', params: { text: 'one' } }],
      next: null,
    });

    const state = scheduledStatuses(initial, {
      type: SCHEDULED_STATUS_DELETE_SUCCESS,
      id: '1',
    });

    expect((state.get('items') as ImmutableList<unknown>).size).toBe(0);
  });

  test('prepends newly scheduled status on compose submit success', () => {
    const initial = scheduledStatuses(undefined, {
      type: SCHEDULED_STATUSES_FETCH_SUCCESS,
      statuses: [{ id: '1', scheduled_at: '2025-01-02T10:00:00.000Z', params: { text: 'one' } }],
      next: null,
    });

    const state = scheduledStatuses(initial, {
      type: COMPOSE_SUBMIT_SUCCESS,
      status: { id: '2', scheduled_at: '2025-01-02T12:00:00.000Z', params: { text: 'two' } },
    });

    expect((state.get('items') as ImmutableList<unknown>).size).toBe(2);
    expect(state.getIn(['items', 0, 'id'])).toBe('2');
  });
});
