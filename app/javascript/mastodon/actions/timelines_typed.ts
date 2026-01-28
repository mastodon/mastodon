import { createAction } from '@reduxjs/toolkit';

import { usePendingItems as preferPendingItems } from 'mastodon/initial_state';

import { createAppThunk } from '../store/typed_functions';

import { expandTimeline, TIMELINE_NON_STATUS_MARKERS } from './timelines';

export const expandTimelineByKey = createAppThunk(
  (args: { key: string; maxId?: number }, { dispatch }) => {
    const params = parseTimelineKey(args.key);
    if (!params) {
      return;
    }

    void dispatch(expandTimelineByParams({ ...params, maxId: args.maxId }));
  },
);

export const expandTimelineByParams = createAppThunk(
  (params: TimelineParams & { maxId?: number }, { dispatch }) => {
    let url = '';
    const extra: Record<string, string | boolean> = {};

    if (params.type === 'account') {
      url = `/api/v1/accounts/${params.userId}/statuses`;

      if (!params.replies) {
        extra.exclude_replies = true;
      }
      if (!params.boosts) {
        extra.exclude_reblogs = true;
      }
      if (params.pinned) {
        extra.pinned = true;
      }
      if (params.media) {
        extra.only_media = true;
      }
      if (params.tagged) {
        extra.tagged = params.tagged;
      }
    } else if (params.type === 'public') {
      url = '/api/v1/timelines/public';
    }

    if (params.maxId) {
      extra.max_id = params.maxId.toString();
    }

    return dispatch(expandTimeline(timelineKey(params), url, extra));
  },
);

export interface AccountTimelineParams {
  type: 'account';
  userId: string;
  tagged?: string;
  media?: boolean;
  pinned?: boolean;
  boosts?: boolean;
  replies?: boolean;
}
export type PublicTimelineServer = 'local' | 'remote' | 'all';
export interface PublicTimelineParams {
  type: 'public';
  tagged?: string;
  server?: PublicTimelineServer; // Defaults to 'all'
  media?: boolean;
}
export interface HomeTimelineParams {
  type: 'home';
}
export type TimelineParams =
  | AccountTimelineParams
  | PublicTimelineParams
  | HomeTimelineParams;

const ACCOUNT_FILTERS = ['boosts', 'replies', 'media', 'pinned'] as const;

export function timelineKey(params: TimelineParams): string {
  const { type } = params;
  const key: string[] = [type];

  if (type === 'account') {
    key.push(params.userId);

    const view = ACCOUNT_FILTERS.reduce(
      (prev, curr) => prev + (params[curr] ? '1' : '0'),
      '',
    );

    key.push(view);
  } else if (type === 'public') {
    key.push(params.server ?? 'all');
    if (params.media) {
      key.push('media');
    }
  }

  if (type !== 'home' && params.tagged) {
    key.push(params.tagged);
  }

  return key.filter(Boolean).join(':');
}

export function parseTimelineKey(key: string): TimelineParams | null {
  const segments = key.split(':');
  const type = segments[0];

  if (type === 'account') {
    const userId = segments[1];
    if (!userId) {
      return null;
    }

    const parsed: TimelineParams = {
      type: 'account',
      userId,
      tagged: segments[3],
    };

    const view = segments[2]?.split('') ?? [];
    for (let i = 0; i < view.length; i++) {
      const flagName = ACCOUNT_FILTERS[i];
      if (flagName) {
        parsed[flagName] = view[i] === '1';
      }
    }
    return parsed;
  }

  if (type === 'public') {
    return {
      type: 'public',
      server:
        segments[1] === 'remote' || segments[1] === 'local'
          ? segments[1]
          : 'all',
      tagged: segments[2],
      media: segments[3] === 'media',
    };
  }

  if (type === 'home') {
    return { type: 'home' };
  }

  return null;
}

export function isNonStatusId(value: unknown) {
  return TIMELINE_NON_STATUS_MARKERS.includes(value as string | null);
}

export const disconnectTimeline = createAction(
  'timeline/disconnect',
  ({ timeline }: { timeline: string }) => ({
    payload: {
      timeline,
      usePendingItems: preferPendingItems,
    },
  }),
);

export const timelineDelete = createAction<{
  statusId: string;
  accountId: string;
  references: string[];
  reblogOf: string | null;
}>('timelines/delete');
