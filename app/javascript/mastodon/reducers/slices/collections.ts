import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

import { importFetchedAccounts } from '@/mastodon/actions/importer';
import {
  apiCreateCollection,
  apiGetAccountCollections,
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
} from '@/mastodon/api_types/collections';
import { me } from '@/mastodon/initial_state';
import {
  createAppAsyncThunk,
  createAppSelector,
  createDataLoadingThunk,
} from '@/mastodon/store/typed_functions';
import { inputToHashtag } from '@/mastodon/utils/hashtags';

type QueryStatus = 'idle' | 'loading' | 'error';

interface CollectionState {
  // Collections mapped by collection id
  collections: Record<string, ApiCollectionJSON>;
  // Lists of collection ids mapped by account id
  accountCollections: Record<
    string,
    {
      collectionIds: string[];
      status: QueryStatus;
    }
  >;
  editor: EditorState;
}

interface EditorState {
  id: string | null;
  name: string;
  description: string;
  topic: string;
  language: string | null;
  discoverable: boolean;
  sensitive: boolean;
  accountIds: string[];
}

interface UpdateEditorFieldPayload<K extends keyof EditorState> {
  field: K;
  value: EditorState[K];
}

const initialState: CollectionState = {
  collections: {},
  accountCollections: {},
  editor: {
    id: null,
    name: '',
    description: '',
    topic: '',
    language: null,
    discoverable: true,
    sensitive: false,
    accountIds: [],
  },
};

const collectionSlice = createSlice({
  name: 'collections',
  initialState,
  reducers: {
    init(state, action: PayloadAction<ApiCollectionJSON | null>) {
      const collection = action.payload;

      state.editor = {
        id: collection?.id ?? null,
        name: collection?.name ?? '',
        description: collection?.description ?? '',
        topic: inputToHashtag(collection?.tag?.name ?? ''),
        language: collection?.language ?? '',
        discoverable: collection?.discoverable ?? true,
        sensitive: collection?.sensitive ?? false,
        accountIds: getCollectionItemIds(collection?.items ?? []),
      };
    },
    reset(state) {
      state.editor = initialState.editor;
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
     * Fetching account collections
     */
    builder.addCase(fetchAccountCollections.pending, (state, action) => {
      const { accountId } = action.meta.arg;
      state.accountCollections[accountId] ??= {
        status: 'loading',
        collectionIds: [],
      };
      state.accountCollections[accountId].status = 'loading';
    });

    builder.addCase(fetchAccountCollections.rejected, (state, action) => {
      const { accountId } = action.meta.arg;
      state.accountCollections[accountId] = {
        status: 'error',
        collectionIds: [],
      };
    });

    builder.addCase(fetchAccountCollections.fulfilled, (state, action) => {
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
      state.accountCollections[action.meta.arg.accountId] = {
        collectionIds,
        status: 'idle',
      };
    });

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
      state.editor = initialState.editor;
    });

    /**
     * Deleting a collection
     */

    builder.addCase(deleteCollection.fulfilled, (state, action) => {
      const { collectionId } = action.meta.arg;
      // eslint-disable-next-line @typescript-eslint/no-dynamic-delete
      delete state.collections[collectionId];
      if (me) {
        let accountCollectionIds = state.accountCollections[me]?.collectionIds;
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
      state.editor = initialState.editor;

      if (state.accountCollections[collection.account_id]) {
        state.accountCollections[collection.account_id]?.collectionIds.unshift(
          collection.id,
        );
      } else {
        state.accountCollections[collection.account_id] = {
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

export const fetchAccountCollections = createDataLoadingThunk(
  `${collectionSlice.name}/fetchAccountCollections`,
  ({ accountId }: { accountId: string }) => apiGetAccountCollections(accountId),
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
    (state) => state.collections.accountCollections,
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

const onlyExistingIds = (id?: string): id is string => !!id;

export const getCollectionItemIds = (items?: ApiCollectionJSON['items']) =>
  items?.map((item) => item.account_id).filter(onlyExistingIds) ?? [];
