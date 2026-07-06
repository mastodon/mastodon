import type { OrderedSet as ImmutableOrderedSet } from 'immutable';

import type { StatusInteractionIntent } from '@/mastodon/actions/interactions_typed';
import type {
  ExpandedStatusShape,
  StatusShape,
} from '@/mastodon/models/status';
import { createAppSelector } from '@/mastodon/store/typed_functions';

import { selectIsAccountLocal, selectPlainAccount } from './accounts';

export const getStatusList = createAppSelector(
  [
    (state, type: 'favourites' | 'bookmarks' | 'pins' | 'trending') =>
      state.status_lists.getIn([type, 'items']) as ImmutableOrderedSet<string>,
  ],
  (items) => items.toList(),
);

export const selectPlainStatus = createAppSelector(
  [(state, statusId?: string | null) => state.statuses.get(statusId ?? '')],
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

export const selectStatusConditions = createAppSelector(
  [
    selectPlainStatus,
    (state) => state.meta.get('me', null) as string | null,
    (state, statusId: string) =>
      state.statuses.getIn([
        state.statuses.getIn([statusId, 'quote', 'quoted_status']),
        'account',
      ]) as string | undefined | null,
    (state, statusId: string) =>
      selectIsAccountLocal(
        state,
        state.statuses.getIn([statusId, 'account']) as string,
      ),
  ],
  (status, userId, quotedAccountId, isLocal) => {
    const isPublic =
      !!status && ['public', 'unlisted'].includes(status.visibility);
    const isMine = status?.account === userId;
    const isMineAndPrivate =
      userId === status?.account && status.visibility === 'private';
    const quoteApproval = status?.quote_approval?.current_user;
    return {
      isPublic,
      isLocal,
      isLoggedIn: !!userId,
      isMine,
      isNotMine: !isMine,
      isQuoted: !!status && !!userId && quotedAccountId === userId,
      isNotDirect: !!status && status.visibility !== 'direct',
      isPrivateReblog:
        userId === status?.account && status.visibility === 'private',
      isBoosted: status?.reblogged ?? false,
      isBoostingAllowed: isPublic || isMineAndPrivate,
      isQuoteAutomaticallyAccepted:
        quoteApproval === 'automatic' && (isPublic || isMineAndPrivate),
      isQuoteManuallyAccepted:
        quoteApproval === 'manual' && (isPublic || isMineAndPrivate),
      isQuoteFollowersOnly:
        status?.quote_approval?.automatic[0] === 'followers' ||
        status?.quote_approval?.manual[0] === 'followers',
    };
  },
);
export type StatusConditions = ReturnType<typeof selectStatusConditions>;

export const selectStatusInteractions = createAppSelector(
  [(_, statusId: string) => statusId, selectStatusConditions],
  (statusId, conditionals) => {
    function addAllowed(conditions: Partial<typeof conditionals>) {
      return {
        ...conditions,
        allowed: Object.values(conditions).every(Boolean),
      };
    }

    const {
      isLoggedIn,
      isMine,
      isNotMine,
      isPublic,
      isLocal,
      isQuoted,
      isNotDirect,
    } = conditionals;

    const interactions: Record<
      StatusInteractionIntent,
      Partial<typeof conditionals> & { allowed: boolean }
    > = {
      bookmark: addAllowed({ isLoggedIn }),
      delete: addAllowed({ isMine }),
      edit: addAllowed({ isMine }),
      editQuotePolicy: addAllowed({ isMine, isPublic }),
      embed: addAllowed({ isPublic, isLocal }),
      favourite: addAllowed({ isLoggedIn }),
      filter: addAllowed({ isLoggedIn, isNotMine }),
      mute: addAllowed({ isMine }),
      pin: addAllowed({ isMine, isNotDirect }),
      quote: addAllowed({ isLoggedIn }),
      reblog: addAllowed({ isLoggedIn }),
      redraft: addAllowed({ isMine }),
      reply: addAllowed({ isLoggedIn }),
      report: addAllowed({ isLoggedIn, isNotMine }),
      revokeQuote: addAllowed({ isQuoted, isNotMine }),
      translate: addAllowed({ isLoggedIn }),
    };

    return {
      statusId,
      ...interactions,
    };
  },
);
export type StatusInteractions = ReturnType<typeof selectStatusInteractions>;

export const selectStatusInteractionsAllowed = createAppSelector(
  [selectStatusInteractions],
  ({ statusId, ...interactions }) => ({
    statusId,
    ...(Object.fromEntries(
      Object.entries(interactions).map(([key, { allowed }]) => [key, allowed]),
    ) as Record<StatusInteractionIntent, boolean>),
  }),
);
export type StatusInteractionsAllowed = ReturnType<
  typeof selectStatusInteractionsAllowed
>;

export const selectStatusIntentAllowed = createAppSelector(
  [
    selectStatusInteractions,
    (_state, _statusId: string, intent: StatusInteractionIntent) => intent,
  ],
  (allowedInteractions, intent) => allowedInteractions[intent].allowed,
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
