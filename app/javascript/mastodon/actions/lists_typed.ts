import { apiCreate, apiUpdate, apiGetLists } from 'mastodon/api/lists';
import type { List } from 'mastodon/models/list';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const createList = createDataLoadingThunk(
  'list/create',
  (list: Partial<List>) => apiCreate(list),
);

export const updateList = createDataLoadingThunk(
  'list/update',
  (list: Partial<List>) => apiUpdate(list),
);

export const fetchLists = createDataLoadingThunk('lists/fetch', () =>
  apiGetLists(),
);
