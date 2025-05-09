import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

import { apiRequestGet } from '../api';
import type { ApiAccountJSON } from '../api_types/accounts';

import { importFetchedAccounts } from './importer';

interface ApiFamiliarFollowersJSON {
  id: string;
  accounts: ApiAccountJSON[];
}

const apiGetFamiliarFollowers = (id: string) =>
  apiRequestGet<ApiFamiliarFollowersJSON[]>('/v1/accounts/familiar_followers', {
    id,
  });

export const fetchAccountsFamiliarFollowers = createDataLoadingThunk(
  'accounts_familiar_followers/fetch',
  ({ id }: { id: string }) => apiGetFamiliarFollowers(id),
  ([data], { dispatch }) => {
    dispatch(importFetchedAccounts(data?.accounts));
    return data;
  },
);
