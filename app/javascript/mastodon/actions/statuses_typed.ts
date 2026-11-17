import { createAction } from '@reduxjs/toolkit';

import { apiGetContext, apiSetQuotePolicy } from 'mastodon/api/statuses';
import {
  createAppThunk,
  createDataLoadingThunk,
} from 'mastodon/store/typed_functions';

import type { ApiQuotePolicy } from '../api_types/quotes';
import { getAncestorsIds, getDescendantsIds } from '../selectors/contexts';
import { selectPlainStatus } from '../selectors/statuses';

import { importFetchedStatuses } from './importer';
import { hideStatus, revealStatus } from './statuses';

export const fetchContext = createDataLoadingThunk(
  'status/context',
  ({ statusId }: { statusId: string; prefetchOnly?: boolean }) =>
    apiGetContext(statusId),
  ({ context, refresh }, { dispatch, actionArg: { prefetchOnly = false } }) => {
    const statuses = context.ancestors.concat(context.descendants);

    dispatch(importFetchedStatuses(statuses));

    return {
      context,
      refresh,
      prefetchOnly,
    };
  },
);

export const completeContextRefresh = createAction<{ statusId: string }>(
  'status/context/complete',
);

export const showPendingReplies = createAction<{ statusId: string }>(
  'status/context/showPendingReplies',
);

export const clearPendingReplies = createAction<{ statusId: string }>(
  'status/context/clearPendingReplies',
);

export const setStatusQuotePolicy = createDataLoadingThunk(
  'status/setQuotePolicy',
  ({ statusId, policy }: { statusId: string; policy: ApiQuotePolicy }) => {
    return apiSetQuotePolicy(statusId, policy);
  },
);

export const toggleThreadCWs = createAppThunk(
  (statusId: string, { getState, dispatch }) => {
    const state = getState();
    const status = selectPlainStatus(state, statusId);
    if (!status) {
      return;
    }

    const ancestorIds = getAncestorsIds(state, statusId);
    const descendantIds = getDescendantsIds(state, statusId);
    const allIds = [statusId, ...ancestorIds, ...descendantIds];

    if (status.hidden) {
      dispatch(revealStatus(allIds));
    } else {
      dispatch(hideStatus(allIds));
    }
  },
);
