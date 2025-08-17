import { createAction } from '@reduxjs/toolkit';

import { apiGetContext, apiSetQuotePolicy } from 'mastodon/api/statuses';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

import type { ApiQuotePolicy } from '../api_types/quotes';

import { importFetchedStatuses } from './importer';

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

export const setStatusQuotePolicy = createDataLoadingThunk(
  'status/setQuotePolicy',
  ({ statusId, policy }: { statusId: string; policy: ApiQuotePolicy }) => {
    return apiSetQuotePolicy(statusId, policy);
  },
);
