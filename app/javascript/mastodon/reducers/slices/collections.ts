import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

import { importFetchedAccounts } from '@/mastodon/actions/importer';
import {
  apiCreateCollection,
  apiGetCollectionsCreatedByAccount,
  apiGetCollectionsFeaturingAccount,
  apiUpdateCollection,
  apiGetCollection,
  apiDeleteCollection,
  apiAddCollectionItem,
  apiRemoveCollectionItem,
  apiRevokeCollectionInclusion,
} from '@/mastodon/api/collections';
import type {
  ApiCollectionJSON,
  ApiCreateCollectionPayload,
  ApiUpdateCollectionPayload,
  CollectionAccountItem,
} from '@/mastodon/api_types/collections';
import { initialState, me } from '@/mastodon/initial_state';
import {
  createAppAsyncThunk,
  createAppSelector,
  createDataLoadingThunk,
} from '@/mastodon/store/typed_functions';
import { inputToHashtag } from '@/mastodon/utils/hashtags';

type QueryStatus = 'idle' | 'loading' | 'error';

// Lists of collection ids and their loading status mapped by account id
type CollectionsByAccountId = Record<
  string,
  {
    collectionIds: string[];
    status: QueryStatus;
  }
>;

interface CollectionState {
  // Full collections mapped by collection id
  collections: Record<string, ApiCollectionJSON>;
  // Collections created by an account, mapped by account id
  createdBy: CollectionsByAccountId;
  // Collections that feature an account, mapped by account id
  featuring: CollectionsByAccountId;
  editor: EditorState;
}

/**
 * This is a subset of the `CollectionAccountItem` type
 * for use in the editor. Here, `account_id` is always defined
 * and `state` is more limited.
 */
export interface EditorCollectionItem {
  account_id: string;
  state: 'pending' | 'accepted';
}

interface EditorState {
  id: string | null;
  name: string;
  description: string;
  topic: string;
  language: string;
  discoverable: boolean;
  sensitive: boolean;
  items: EditorCollectionItem[];
}

interface UpdateEditorFieldPayload<K extends keyof EditorState> {
  field: K;
  value: EditorState[K];
}

const initialCollectionState: CollectionState = {
  collections: {},
  createdBy: {},
  featuring: {},
  editor: {
    id: null,
    name: '',
    description: '',
    topic: '',
    language: initialState?.compose.default_language ?? 'en',
    discoverable: true,
    sensitive: false,
    items: [],
  },
};

const collectionSlice = createSlice({
  name: 'collections',
  initialState: initialCollectionState,
  reducers: {
    init(state, action: PayloadAction<ApiCollectionJSON>) {
      const collection = action.payload;

      state.editor = {
        id: collection.id,
        name: collection.name,
        description: collection.description ?? '',
        topic: inputToHashtag(collection.tag?.name ?? ''),
        language: collection.language ?? '',
        discoverable: collection.discoverable,
        sensitive: collection.sensitive,
        items: getEditorCollectionItems(collection.items),
      };
    },
    reset(state) {
      state.editor = initialCollectionState.editor;
    },
    updateEditorField<K extends keyof EditorState>(
      state: CollectionState,
      action: PayloadAction<UpdateEditorFieldPayload<K>>,
    ) {
      const { field, value } = action.payload;
      state.editor[field] = value;
    },
  },
  extraReducers(builder) {
    /**
     * Fetching collections created by account
     */
    builder.addCase(
      fetchCollectionsCreatedByAccount.pending,
      (state, action) => {
        const { accountId } = action.meta.arg;
        state.createdBy[accountId] ??= {
          status: 'loading',
          collectionIds: [],
        };
        state.createdBy[accountId].status = 'loading';
      },
    );

    builder.addCase(
      fetchCollectionsCreatedByAccount.rejected,
      (state, action) => {
        const { accountId } = action.meta.arg;
        state.createdBy[accountId] = {
          status: 'error',
          collectionIds: [],
        };
      },
    );

    builder.addCase(
      fetchCollectionsCreatedByAccount.fulfilled,
      (state, action) => {
        const { collections } = action.payload;

        const collectionsMap: Record<string, ApiCollectionJSON> =
          state.collections;
        const collectionIds: string[] = [];

        collections.forEach((collection) => {
          const { id } = collection;
          collectionsMap[id] = collection;
          collectionIds.push(id);
        });

        state.collections = collectionsMap;
        state.createdBy[action.meta.arg.accountId] = {
          collectionIds,
          status: 'idle',
        };
      },
    );
    /**
     * Fetching collections featuring an account
     */
    builder.addCase(
      fetchCollectionsFeaturingAccount.pending,
      (state, action) => {
        const { accountId } = action.meta.arg;
        state.featuring[accountId] ??= {
          status: 'loading',
          collectionIds: [],
        };
        state.featuring[accountId].status = 'loading';
      },
    );

    builder.addCase(
      fetchCollectionsFeaturingAccount.rejected,
      (state, action) => {
        const { accountId } = action.meta.arg;
        state.featuring[accountId] = {
          status: 'error',
          collectionIds: [],
        };
      },
    );

    builder.addCase(
      fetchCollectionsFeaturingAccount.fulfilled,
      (state, action) => {
        const { collections } = action.payload;

        const collectionsMap: Record<string, ApiCollectionJSON> =
          state.collections;
        const collectionIds: string[] = [];

        collections.forEach((collection) => {
          const { id } = collection;
          collectionsMap[id] = collection;
          collectionIds.push(id);
        });

        state.collections = collectionsMap;
        state.featuring[action.meta.arg.accountId] = {
          collectionIds,
          status: 'idle',
        };
      },
    );

    /**
     * Fetching a single collection
     */

    builder.addCase(fetchCollection.fulfilled, (state, action) => {
      const { collection } = action.payload;
      state.collections[collection.id] = collection;
    });

    /**
     * Updating a collection
     */

    builder.addCase(updateCollection.fulfilled, (state, action) => {
      const { collection } = action.payload;
      state.collections[collection.id] = collection;
      state.editor = initialCollectionState.editor;
    });

    /**
     * Deleting a collection
     */

    builder.addCase(deleteCollection.fulfilled, (state, action) => {
      const { collectionId } = action.meta.arg;
      // eslint-disable-next-line @typescript-eslint/no-dynamic-delete
      delete state.collections[collectionId];
      if (me) {
        let accountCollectionIds = state.createdBy[me]?.collectionIds;
        if (accountCollectionIds) {
          accountCollectionIds = accountCollectionIds.filter(
            (id) => id !== collectionId,
          );
        }
      }
    });

    /**
     * Creating a collection
     */

    builder.addCase(createCollection.fulfilled, (state, actions) => {
      const { collection } = actions.payload;

      state.collections[collection.id] = collection;
      state.editor = initialCollectionState.editor;

      if (state.createdBy[collection.account_id]) {
        state.createdBy[collection.account_id]?.collectionIds.unshift(
          collection.id,
        );
      } else {
        state.createdBy[collection.account_id] = {
          collectionIds: [collection.id],
          status: 'idle',
        };
      }
    });

    /**
     * Adding an account to a collection
     */

    builder.addCase(addCollectionItem.fulfilled, (state, action) => {
      const { collection_item } = action.payload;
      const { collectionId } = action.meta.arg;

      state.collections[collectionId]?.items.push(collection_item);
    });

    /**
     * Removing an account from a collection
     */

    const removeAccountFromCollection = (
      state: CollectionState,
      action: { meta: { arg: { itemId: string; collectionId: string } } },
    ) => {
      const { itemId, collectionId } = action.meta.arg;

      const collection = state.collections[collectionId];
      if (collection) {
        collection.items = collection.items.filter(
          (item) => item.id !== itemId,
        );
      }
    };

    builder.addCase(
      removeCollectionItem.fulfilled,
      removeAccountFromCollection,
    );

    builder.addCase(
      revokeCollectionInclusion.fulfilled,
      removeAccountFromCollection,
    );
  },
});

export const fetchCollectionsCreatedByAccount = createDataLoadingThunk(
  `${collectionSlice.name}/fetchCollectionsCreatedByAccount`,
  ({ accountId }: { accountId: string }) =>
    apiGetCollectionsCreatedByAccount(accountId),
);

export const fetchCollectionsFeaturingAccount = createDataLoadingThunk(
  `${collectionSlice.name}/fetchCollectionsFeaturingAccount`,
  ({ accountId }: { accountId: string }) =>
    apiGetCollectionsFeaturingAccount(accountId),
);

export const fetchCollection = createDataLoadingThunk(
  `${collectionSlice.name}/fetchCollection`,
  ({ collectionId }: { collectionId: string }) =>
    apiGetCollection(collectionId),
  (payload, { dispatch }) => {
    if (payload.accounts.length > 0) {
      dispatch(importFetchedAccounts(payload.accounts));
    }
    return payload;
  },
);

export const createCollection = createDataLoadingThunk(
  `${collectionSlice.name}/createCollection`,
  ({ payload }: { payload: ApiCreateCollectionPayload }) =>
    apiCreateCollection(payload),
);

export const updateCollection = createDataLoadingThunk(
  `${collectionSlice.name}/updateCollection`,
  ({ payload }: { payload: ApiUpdateCollectionPayload }) =>
    apiUpdateCollection(payload),
);

export const deleteCollection = createDataLoadingThunk(
  `${collectionSlice.name}/deleteCollection`,
  ({ collectionId }: { collectionId: string }) =>
    apiDeleteCollection(collectionId),
);

export const addCollectionItem = createDataLoadingThunk(
  `${collectionSlice.name}/addCollectionItem`,
  ({ collectionId, accountId }: { collectionId: string; accountId: string }) =>
    apiAddCollectionItem(collectionId, accountId),
);

export const removeCollectionItem = createDataLoadingThunk(
  `${collectionSlice.name}/removeCollectionItem`,
  ({ collectionId, itemId }: { collectionId: string; itemId: string }) =>
    apiRemoveCollectionItem(collectionId, itemId),
);

export const revokeCollectionInclusion = createAppAsyncThunk(
  `${collectionSlice.name}/revokeCollectionInclusion`,
  ({ collectionId, itemId }: { collectionId: string; itemId: string }) =>
    apiRevokeCollectionInclusion(collectionId, itemId),
);

export const collections = collectionSlice.reducer;
export const collectionEditorActions = collectionSlice.actions;
export const updateCollectionEditorField =
  collectionSlice.actions.updateEditorField;

/**
 * Selectors
 */

interface AccountCollectionQuery {
  status: QueryStatus;
  collections: ApiCollectionJSON[];
}

export const selectAccountCollections = createAppSelector(
  [
    (_, accountId?: string | null) => accountId,
    (state, _, query: 'createdBy' | 'featuring') => state.collections[query],
    (state) => state.collections.collections,
  ],
  (accountId, collectionsByAccountId, collectionsMap) => {
    const myCollectionsQuery = accountId
      ? collectionsByAccountId[accountId]
      : null;

    if (!myCollectionsQuery) {
      return {
        status: 'error',
        collections: [] as ApiCollectionJSON[],
      } satisfies AccountCollectionQuery;
    }

    const { status, collectionIds } = myCollectionsQuery;

    return {
      status,
      collections: collectionIds
        .map((id) => collectionsMap[id])
        .filter((c) => !!c),
    } satisfies AccountCollectionQuery;
  },
);

const isEditorItem = (
  item: Partial<CollectionAccountItem>,
): item is EditorCollectionItem =>
  !!item.account_id && (item.state === 'accepted' || item.state === 'pending');

export const getEditorCollectionItems = (items?: CollectionAccountItem[]) =>
  items
    ?.map(({ account_id, state }) => ({ account_id, state }))
    .filter(isEditorItem) ?? [];
