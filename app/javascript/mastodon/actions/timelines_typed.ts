import { createAction } from '@reduxjs/toolkit';

import { usePendingItems as preferPendingItems } from 'mastodon/initial_state';

import { createAppThunk } from '../store/typed_functions';

import { expandTimeline, TIMELINE_NON_STATUS_MARKERS } from './timelines';

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

export function timelineKey(params: TimelineParams): string {
  const { type } = params;
  const key: string[] = [type];

  if (type === 'account') {
    const view = (['media', 'pinned', 'boosts', 'replies'] as const).reduce(
      (prev, curr) => prev + (params[curr] ? curr.charAt(0) : ''),
      '',
    );
    key.push(params.userId);
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

export const expandTimelineByParams = createAppThunk(
  (params: TimelineParams, { dispatch }) => {
    let url = '';
    const extra: Record<string, string | boolean> = {};
    if (params.type === 'account') {
      url = `/api/v1/accounts/${params.userId}/statuses`;
    } else if (params.type === 'public') {
      url = '/api/v1/timelines/public';
    }

    return dispatch(expandTimeline(timelineKey(params), url, extra));
  },
);

export function parseTimelineKey(key: string): TimelineParams | null {
  const segments = key.split(':');
  const type = segments[0];

  if (type === 'account') {
    const userId = segments[1];
    if (!userId) {
      return null;
    }
    const view = segments[2]?.split('') ?? [];
    return {
      type: 'account',
      userId,
      tagged: segments[3],
      media: view.includes('m'),
      pinned: view.includes('p'),
      boosts: view.includes('b'),
      replies: view.includes('r'),
    };
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
