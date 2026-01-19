import type { List as ImmutableList } from 'immutable';

import { apiGetDirectory } from 'mastodon/api/directory';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

import { fetchRelationships } from './accounts';
import { importFetchedAccounts } from './importer';

const DIRECTORY_FETCH_LIMIT = 20;

export const fetchDirectory = createDataLoadingThunk(
  'directory/fetch',
  async (params: Parameters<typeof apiGetDirectory>[0]) =>
    apiGetDirectory(params, DIRECTORY_FETCH_LIMIT),
  (data, { dispatch }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(fetchRelationships(data.map((x) => x.id)));

    return { accounts: data, isLast: data.length < DIRECTORY_FETCH_LIMIT };
  },
);

export const expandDirectory = createDataLoadingThunk(
  'directory/expand',
  async (params: Parameters<typeof apiGetDirectory>[0], { getState }) => {
    const loadedItems = getState().user_lists.getIn([
      'directory',
      'items',
    ]) as ImmutableList<unknown>;

    return apiGetDirectory(
      { ...params, offset: loadedItems.size },
      DIRECTORY_FETCH_LIMIT,
    );
  },
  (data, { dispatch }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(fetchRelationships(data.map((x) => x.id)));

    return { accounts: data, isLast: data.length < DIRECTORY_FETCH_LIMIT };
  },
);
