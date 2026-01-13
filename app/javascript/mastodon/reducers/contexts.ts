/* eslint-disable @typescript-eslint/no-dynamic-delete */
import { createReducer } from '@reduxjs/toolkit';
import type { Draft, UnknownAction } from '@reduxjs/toolkit';
import type { List as ImmutableList } from 'immutable';

import { timelineDelete } from 'mastodon/actions/timelines_typed';
import type { AsyncRefreshHeader } from 'mastodon/api';
import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';
import type {
  ApiStatusJSON,
  ApiContextJSON,
} from 'mastodon/api_types/statuses';
import type { Status } from 'mastodon/models/status';

import { blockAccountSuccess, muteAccountSuccess } from '../actions/accounts';
import {
  fetchContext,
  completeContextRefresh,
  showPendingReplies,
  clearPendingReplies,
} from '../actions/statuses';
import { TIMELINE_UPDATE } from '../actions/timelines';
import { compareId } from '../compare_id';

interface TimelineUpdateAction extends UnknownAction {
  timeline: string;
  status: ApiStatusJSON;
  usePendingItems: boolean;
}

interface State {
  inReplyTos: Record<string, string>;
  replies: Record<string, string[]>;
  pendingReplies: Record<
    string,
    Pick<ApiStatusJSON, 'id' | 'in_reply_to_id'>[]
  >;
  refreshing: Record<string, AsyncRefreshHeader>;
}

const initialState: State = {
  inReplyTos: {},
  replies: {},
  pendingReplies: {},
  refreshing: {},
};

const addReply = (
  state: Draft<State>,
  { id, in_reply_to_id }: Pick<ApiStatusJSON, 'id' | 'in_reply_to_id'>,
) => {
  if (!in_reply_to_id) {
    return;
  }

  if (!state.inReplyTos[id]) {
    const siblings = (state.replies[in_reply_to_id] ??= []);
    const index = siblings.findIndex((sibling) => compareId(sibling, id) < 0);
    siblings.splice(index + 1, 0, id);
    state.inReplyTos[id] = in_reply_to_id;
  }
};

const normalizeContext = (
  state: Draft<State>,
  id: string,
  { ancestors, descendants }: ApiContextJSON,
): void => {
  ancestors.forEach((item) => {
    addReply(state, item);
  });

  // We know in_reply_to_id of statuses but `id` itself.
  // So we assume that the status of the id replies to last ancestors.
  if (ancestors[0]) {
    addReply(state, {
      id,
      in_reply_to_id: ancestors[ancestors.length - 1]?.id,
    });
  }

  descendants.forEach((item) => {
    addReply(state, item);
  });
};

const applyPrefetchedReplies = (state: Draft<State>, statusId: string) => {
  const pendingReplies = state.pendingReplies[statusId];
  if (pendingReplies?.length) {
    pendingReplies.forEach((item) => {
      addReply(state, item);
    });
    delete state.pendingReplies[statusId];
  }
};

const storePrefetchedReplies = (
  state: Draft<State>,
  statusId: string,
  { descendants }: ApiContextJSON,
): void => {
  descendants.forEach(({ id, in_reply_to_id }) => {
    if (!in_reply_to_id) {
      return;
    }
    const isNewReply = !state.replies[in_reply_to_id]?.includes(id);
    if (isNewReply) {
      const pendingReplies = (state.pendingReplies[statusId] ??= []);
      pendingReplies.push({ id, in_reply_to_id });
    }
  });
};

const deleteFromContexts = (state: Draft<State>, ids: string[]): void => {
  ids.forEach((id) => {
    const inReplyToIdOfId = state.inReplyTos[id];
    const repliesOfId = state.replies[id];

    if (inReplyToIdOfId) {
      const siblings = state.replies[inReplyToIdOfId];

      if (siblings) {
        state.replies[inReplyToIdOfId] = siblings.filter(
          (sibling) => sibling !== id,
        );
      }
    }

    if (repliesOfId) {
      repliesOfId.forEach((reply) => {
        delete state.inReplyTos[reply];
      });
    }

    delete state.inReplyTos[id];
    delete state.replies[id];
  });
};

const filterContexts = (
  state: Draft<State>,
  relationship: ApiRelationshipJSON,
  statuses: ImmutableList<Status>,
): void => {
  const ownedStatusIds = statuses
    .filter((status) => (status.get('account') as string) === relationship.id)
    .map((status) => status.get('id') as string);

  deleteFromContexts(state, ownedStatusIds.toArray());
};

const updateContext = (state: Draft<State>, status: ApiStatusJSON): void => {
  if (!status.in_reply_to_id) {
    return;
  }

  const siblings = (state.replies[status.in_reply_to_id] ??= []);

  state.inReplyTos[status.id] = status.in_reply_to_id;

  if (!siblings.includes(status.id)) {
    siblings.push(status.id);
  }
};

export const contextsReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(fetchContext.fulfilled, (state, action) => {
      const currentReplies = state.replies[action.meta.arg.statusId] ?? [];
      const hasReplies = currentReplies.length > 0;
      // Ignore prefetchOnly if there are no replies - then we can load them immediately
      if (action.payload.prefetchOnly && hasReplies) {
        storePrefetchedReplies(
          state,
          action.meta.arg.statusId,
          action.payload.context,
        );
      } else {
        normalizeContext(
          state,
          action.meta.arg.statusId,
          action.payload.context,
        );

        if (action.payload.refresh && !action.payload.prefetchOnly) {
          state.refreshing[action.meta.arg.statusId] = action.payload.refresh;
        }
      }
    })
    .addCase(showPendingReplies, (state, action) => {
      applyPrefetchedReplies(state, action.payload.statusId);
    })
    .addCase(clearPendingReplies, (state, action) => {
      delete state.pendingReplies[action.payload.statusId];
    })
    .addCase(completeContextRefresh, (state, action) => {
      delete state.refreshing[action.payload.statusId];
    })
    .addCase(blockAccountSuccess, (state, action) => {
      filterContexts(
        state,
        action.payload.relationship,
        action.payload.statuses as ImmutableList<Status>,
      );
    })
    .addCase(muteAccountSuccess, (state, action) => {
      filterContexts(
        state,
        action.payload.relationship,
        action.payload.statuses as ImmutableList<Status>,
      );
    })
    .addCase(timelineDelete, (state, action) => {
      deleteFromContexts(state, [action.payload.statusId]);
    })
    .addMatcher(
      (action: UnknownAction): action is TimelineUpdateAction =>
        action.type === TIMELINE_UPDATE,
      (state, action) => {
        updateContext(state, action.status);
      },
    );
});
