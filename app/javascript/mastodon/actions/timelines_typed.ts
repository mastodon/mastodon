import { createAction } from '@reduxjs/toolkit';
import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { usePendingItems as preferPendingItems } from 'mastodon/initial_state';

import type { Status } from '../models/status';
import { createAppThunk } from '../store/typed_functions';

import {
  expandTimeline,
  insertIntoTimeline,
  TIMELINE_NON_STATUS_MARKERS,
  updateTimeline,
} from './timelines';

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
      pinned: false,
      boosts: false,
      replies: false,
      media: false,
    };

    // Handle legacy keys.
    const flagsSegment = segments[2];
    if (!flagsSegment || !/^[01]{4}$/.test(flagsSegment)) {
      if (flagsSegment === 'pinned') {
        parsed.pinned = true;
      } else if (flagsSegment === 'with_replies') {
        parsed.replies = true;
      } else if (flagsSegment === 'media') {
        parsed.media = true;
      }
      return parsed;
    }

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

export function isTimelineKeyPinned(key: string, accountId?: string) {
  const parsedKey = parseTimelineKey(key);
  const isPinned = parsedKey?.type === 'account' && parsedKey.pinned;
  if (!accountId || !isPinned) {
    return isPinned;
  }
  return parsedKey.userId === accountId;
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

export const timelineDeleteStatus = createAction<{
  statusId: string;
  timelineKey: string;
}>('timelines/deleteStatus');

/** Minimal status fields needed to decide which account timelines to update. */
export interface AccountTimelineStatusLike {
  id: string;
  account: { id: string };
  visibility: string;
  in_reply_to_id: string | null;
  reblog: unknown;
  media_attachments?: unknown[] | null;
  tags?: { name: string }[] | null;
}

/**
 * Whether a newly created status belongs in the given account timeline view
 * (posts / replies / media / tagged filters). Pinned timelines are excluded.
 */
export function accountTimelineAcceptsStatus(
  params: AccountTimelineParams,
  status: AccountTimelineStatusLike,
): boolean {
  if (params.userId !== status.account.id) {
    return false;
  }

  if (params.pinned) {
    return false;
  }

  if (status.visibility === 'direct') {
    return false;
  }

  const isReply = status.in_reply_to_id != null;
  if (isReply && !params.replies) {
    return false;
  }

  const isReblog = status.reblog != null;
  if (isReblog && !params.boosts) {
    return false;
  }

  if (params.media) {
    const mediaCount = status.media_attachments?.length ?? 0;
    if (mediaCount === 0) {
      return false;
    }
  }

  if (params.tagged) {
    const tagNames = status.tags?.map((tag) => tag.name) ?? [];
    if (!tagNames.includes(params.tagged)) {
      return false;
    }
  }

  return true;
}

/**
 * Optimistically insert a status into loaded account timelines that would
 * display it (own profile after compose). Account timelines are not streamed,
 * so we do not require `online` — only that the timeline is already populated.
 */
export const insertStatusIntoAccountTimelines = createAppThunk(
  (status: AccountTimelineStatusLike, { dispatch, getState }) => {
    const accountId = status.account.id;
    const timelines = getState().timelines as ImmutableMap<
      string,
      ImmutableMap<string, unknown>
    >;

    timelines.forEach((timeline, key) => {
      if (
        !key.startsWith(`account:${accountId}:`) &&
        key !== `account:${accountId}`
      ) {
        return;
      }

      const parsed = parseTimelineKey(key);
      if (parsed?.type !== 'account') {
        return;
      }

      if (!accountTimelineAcceptsStatus(parsed, status)) {
        return;
      }

      const items = timeline.get('items') as
        | ImmutableList<string | null>
        | undefined;
      if (
        !items ||
        items.size === 0 ||
        items.get(0) === null ||
        items.includes(status.id)
      ) {
        return;
      }

      // Avoid inserting into partial timelines that will be reloaded anyway
      if (timeline.get('isPartial')) {
        return;
      }

      dispatch(updateTimeline(key, status));
    });
  },
);

export const insertPinnedStatusIntoTimelines = createAppThunk(
  (status: Status, { dispatch, getState }) => {
    const currentAccountId = getState().meta.get('me', null) as string | null;
    if (!currentAccountId) {
      return;
    }

    const tags =
      (
        status.get('tags') as
          | ImmutableList<ImmutableMap<'name', string>> // We only care about the tag name.
          | undefined
      )
        ?.map((tag) => tag.get('name') as string)
        .toArray() ?? [];

    const timelines = getState().timelines as ImmutableMap<string, unknown>;
    const accountTimelines = timelines.filter((_, key) => {
      if (!key.startsWith(`account:${currentAccountId}:`)) {
        return false;
      }
      const parsed = parseTimelineKey(key);
      const isPinned = parsed?.type === 'account' && parsed.pinned;
      if (!isPinned) {
        return false;
      }

      return !parsed.tagged || tags.includes(parsed.tagged);
    });

    accountTimelines.forEach((_, key) => {
      dispatch(insertIntoTimeline(key, status.get('id') as string, 0));
    });
  },
);

export const removePinnedStatusFromTimelines = createAppThunk(
  (status: Status, { dispatch, getState }) => {
    const currentAccountId = getState().meta.get('me', null) as string | null;
    if (!currentAccountId) {
      return;
    }

    const statusId = status.get('id') as string;
    const timelines = getState().timelines as ImmutableMap<
      string,
      ImmutableMap<'items' | 'pendingItems', ImmutableList<string>>
    >;

    timelines.forEach((timeline, key) => {
      if (!isTimelineKeyPinned(key, currentAccountId)) {
        return;
      }

      if (
        timeline.get('items')?.includes(statusId) ||
        timeline.get('pendingItems')?.includes(statusId)
      ) {
        dispatch(timelineDeleteStatus({ statusId, timelineKey: key }));
      }
    });
  },
);
