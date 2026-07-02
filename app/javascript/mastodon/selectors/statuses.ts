import type { OrderedSet as ImmutableOrderedSet } from 'immutable';

import { createAppSelector } from 'mastodon/store';

import type { StatusInteractionIntent } from '../actions/interactions_typed';
import type { ExpandedStatusShape, StatusShape } from '../models/status';

import { selectPlainAccount } from './accounts';
import type { FilterShape } from './filters';
import { getFilters } from './filters';

export const getStatusList = createAppSelector(
  [
    (state, type: 'favourites' | 'bookmarks' | 'pins' | 'trending') =>
      state.status_lists.getIn([type, 'items']) as ImmutableOrderedSet<string>,
  ],
  (items) => items.toList(),
);

export const selectPlainStatus = createAppSelector(
  [(state, statusId: string) => state.statuses.get(statusId)],
  (status) => {
    if (!status) {
      return null;
    }
    return status.toJS() as unknown as StatusShape;
  },
);

export const selectAccountStatus = createAppSelector(
  [
    selectPlainStatus,
    (state, statusId: string) => {
      const accountId = state.statuses.getIn([statusId, 'account']);
      if (typeof accountId !== 'string') {
        return null;
      }
      return selectPlainAccount(state, accountId);
    },
  ],
  (status, account) => {
    if (!status || !account) {
      return null;
    }
    return {
      ...status,
      account,
    };
  },
);

export const selectExpandedStatus = createAppSelector(
  [
    selectAccountStatus,
    (state, statusId: string) => {
      const reblogId = state.statuses.getIn([statusId, 'reblog']);
      if (typeof reblogId !== 'string') {
        return null;
      }
      return selectAccountStatus(state, reblogId);
    },
  ],
  (status, reblog): ExpandedStatusShape | null => {
    if (!status) {
      return null;
    }

    return {
      ...status,
      reblog: reblog ?? undefined,
    };
  },
);

export const selectStatusInteractions = createAppSelector(
  [
    selectPlainStatus,
    (state) => state.meta.get('me', null) as string | null,
    (state, statusId: string) =>
      state.statuses.getIn([
        state.statuses.getIn([statusId, 'quote', 'quoted_status']),
        'account',
      ]) as string | undefined | null,
  ],
  (status, currentAccountId, quotedAccountId) => {
    if (!status) {
      return null;
    }
    const isPublic = ['public', 'unlisted'].includes(status.visibility);
    const isLoggedIn = !!currentAccountId;
    const isMine = status.account === currentAccountId;

    return {
      statusId: status.id,
      bookmark: isLoggedIn,
      delete: isMine,
      edit: isMine,
      editQuotePolicy: isMine && isPublic,
      embed: isPublic,
      favourite: isLoggedIn,
      filter: isLoggedIn,
      mute: isMine,
      pin: isMine && status.visibility !== 'direct',
      quote: isLoggedIn,
      reblog: isLoggedIn,
      redraft: isMine,
      reply: isLoggedIn,
      report: isLoggedIn,
      revokeQuote: isLoggedIn && currentAccountId === quotedAccountId,
    } satisfies Record<StatusInteractionIntent, boolean> & { statusId: string };
  },
);

export const selectStatusIntentAllowed = createAppSelector(
  [
    selectStatusInteractions,
    (_state, _statusId: string, intent: StatusInteractionIntent) => intent,
  ],
  (allowedInteractions, intent) => allowedInteractions?.[intent] ?? false,
);

export const selectPictureInPicture = createAppSelector(
  [
    (state, statusId: string) =>
      state.picture_in_picture.type !== null &&
      state.picture_in_picture.statusId === statusId,
    (state) => state.meta.get('layout') !== 'mobile',
  ],
  (inUse, available) => ({
    inUse: inUse && available,
    available,
  }),
);

export const selectMediaMatchFilters = createAppSelector(
  [
    (state, { statusId }: { statusId: string }) =>
      selectPlainStatus(state, statusId),
    getFilters,
  ],
  (status, immutableFilters) => {
    const filters = immutableFilters
      ? (immutableFilters.toJS() as unknown as Record<string, FilterShape>)
      : null;
    const mediaFilters: string[] = [];
    if (status?.filtered && filters) {
      for (const { filter } of status.filtered) {
        if (filters[filter]?.filter_action === 'blur') {
          mediaFilters.push(filters[filter].title);
        }
      }
    }

    return mediaFilters;
  },
);
