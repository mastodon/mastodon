import type { MouseEvent } from 'react';

import { createAction } from '@reduxjs/toolkit';

import { apiGetContext, apiSetQuotePolicy } from 'mastodon/api/statuses';
import {
  createAppThunk,
  createDataLoadingThunk,
} from 'mastodon/store/typed_functions';

import type { ApiQuotePolicy } from '../api_types/quotes';
import type { RootState } from '../store';

import { replyCompose } from './compose';
import { importFetchedStatuses } from './importer';
import {
  bookmark,
  toggleFavourite,
  toggleReblog,
  unbookmark,
} from './interactions';
import { openModal } from './modal';

export const fetchContext = createDataLoadingThunk(
  'status/context',
  ({ statusId }: { statusId: string }) => apiGetContext(statusId),
  ({ context, refresh }, { dispatch }) => {
    const statuses = context.ancestors.concat(context.descendants);

    dispatch(importFetchedStatuses(statuses));

    return {
      context,
      refresh,
    };
  },
);

export const completeContextRefresh = createAction<{ statusId: string }>(
  'status/context/complete',
);

type StatusAction<T extends Record<string, unknown> = Record<string, unknown>> =
  T & {
    statusId: string;
  };

export const statusReply = createAppThunk(
  ({ statusId }: StatusAction, { getState, dispatch }) => {
    const state = getState();
    const status = state.statuses.get(statusId);
    if (!status) {
      return;
    }

    if (!isLoggedIn(getState)) {
      showInteractionModal({ statusId, type: 'reply' });
      return;
    }

    // Signed in, open the reply composer.
    if ((state.compose.get('text') as string).trim().length !== 0) {
      dispatch(
        openModal({ modalType: 'CONFIRM_REPLY', modalProps: { status } }),
      );
    } else {
      dispatch(replyCompose(status));
    }
  },
);

export const statusReblog = createAppThunk(
  (
    { statusId, event }: StatusAction<{ event: MouseEvent }>,
    { getState, dispatch },
  ) => {
    if (!isLoggedIn(getState)) {
      showInteractionModal({ statusId, type: 'reblog' });
    } else {
      dispatch(toggleReblog(statusId, event.shiftKey));
    }
  },
);

export const statusFavourite = createAppThunk(
  ({ statusId }: StatusAction, { getState, dispatch }) => {
    if (!isLoggedIn(getState)) {
      showInteractionModal({ statusId, type: 'favourite' });
    } else {
      dispatch(toggleFavourite(statusId));
    }
  },
);

export const statusBookmark = createAppThunk(
  ({ statusId }: StatusAction, { getState, dispatch }) => {
    const state = getState();
    const status = state.statuses.get(statusId);
    if (!status) {
      return;
    }

    if (status.get('bookmarked')) {
      dispatch(unbookmark(status));
    } else {
      dispatch(bookmark(status));
    }
  },
);

export const setStatusQuotePolicy = createDataLoadingThunk(
  'status/setQuotePolicy',
  ({ statusId, policy }: StatusAction<{ policy: ApiQuotePolicy }>) => {
    return apiSetQuotePolicy(statusId, policy);
  },
);

const isLoggedIn = (getState: () => RootState) => !!getState().meta.get('me');

const showInteractionModal = createAppThunk(
  (
    { statusId, type }: StatusAction<{ type: string }>,
    { getState, dispatch },
  ) => {
    const status = getState().statuses.get(statusId);
    if (!status) {
      return;
    }
    dispatch(
      openModal({
        modalType: 'INTERACTION',
        modalProps: {
          type,
          accountId: status.getIn(['account', 'id']),
          url: status.get('uri'),
        },
      }),
    );
  },
);
