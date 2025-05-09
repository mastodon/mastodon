import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

import { apiGetFamiliarFollowers } from '../api/accounts';

import { importFetchedAccounts } from './importer';

export const fetchAccountsFamiliarFollowers = createDataLoadingThunk(
  'accounts_familiar_followers/fetch',
  ({ id }: { id: string }) => apiGetFamiliarFollowers(id),
  ([data], { dispatch }) => {
    dispatch(importFetchedAccounts(data?.accounts));
    return data;
  },
);
