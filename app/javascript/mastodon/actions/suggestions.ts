import {
  apiGetSuggestions,
  apiDeleteSuggestion,
} from 'mastodon/api/suggestions';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

import { fetchRelationships } from './accounts';
import { importFetchedAccounts } from './importer';

export const fetchSuggestions = createDataLoadingThunk(
  'suggestions/fetch',
  () => apiGetSuggestions(20),
  (data, { dispatch }) => {
    dispatch(importFetchedAccounts(data.map((x) => x.account)));
    dispatch(fetchRelationships(data.map((x) => x.account.id)));

    return data;
  },
);

export const dismissSuggestion = createDataLoadingThunk(
  'suggestions/dismiss',
  ({ accountId }: { accountId: string }) => apiDeleteSuggestion(accountId),
);
