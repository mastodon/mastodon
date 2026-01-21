import { createSlice } from '@reduxjs/toolkit';

import {
  apiCreateCollection,
  apiGetAccountCollections,
  // apiGetCollection,
} from '@/mastodon/api/collections';
import type {
  ApiBaseCollectionJSON,
  ApiCreateCollectionPayload,
  ApiFullCollectionJSON,
} from '@/mastodon/api_types/collections';
import {
  createAppSelector,
  createDataLoadingThunk,
} from '@/mastodon/store/typed_functions';

type QueryStatus = 'idle' | 'loading' | 'error';

interface CollectionState {
  // Collections mapped by collection id
  collections: Record<string, ApiBaseCollectionJSON | ApiFullCollectionJSON>;
  // Lists of collection ids mapped by account id
  accountCollections: Record<
    string,
    {
      collectionIds: string[];
      status: QueryStatus;
    }
  >;
}

const initialState: CollectionState = {
  collections: {},
  accountCollections: {},
};

const collectionSlice = createSlice({
  name: 'collections',
  initialState,
  reducers: {},
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

    builder.addCase(fetchAccountCollections.fulfilled, (state, actions) => {
      const { payload, meta } = actions;

      const collectionsMap: Record<string, ApiBaseCollectionJSON> = {};
      const collectionIds: string[] = [];

      payload.forEach((collection) => {
        const { id } = collection;
        collectionsMap[id] = collection;
        collectionIds.push(id);
      });

      state.collections = collectionsMap;
      state.accountCollections[meta.arg.accountId] = {
        collectionIds,
        status: 'idle',
      };
    });

    /**
     * Creating a collection
     */

    builder.addCase(createCollection.fulfilled, (state, actions) => {
      const { payload } = actions;

      state.collections[payload.id] = payload;
      if (state.accountCollections[payload.account.id]) {
        state.accountCollections[payload.account.id]?.collectionIds.unshift(
          payload.id,
        );
      } else {
        state.accountCollections[payload.account.id] = {
          collectionIds: [payload.id],
          status: 'idle',
        };
      }
    });
  },
});

export const fetchAccountCollections = createDataLoadingThunk(
  `${collectionSlice.name}/fetchAccountCollections`,
  ({ accountId }: { accountId: string }) => apiGetAccountCollections(accountId),
);

// To be added soon…
//
// export const fetchCollection = createDataLoadingThunk(
//   `${collectionSlice.name}/fetchCollection`,
//   ({ collectionId }: { collectionId: string }) =>
//     apiGetCollection(collectionId),
// );

export const createCollection = createDataLoadingThunk(
  `${collectionSlice.name}/createCollection`,
  ({ payload }: { payload: ApiCreateCollectionPayload }) =>
    apiCreateCollection(payload),
);

export const collections = collectionSlice.reducer;

/**
 * Selectors
 */

interface AccountCollectionQuery {
  status: QueryStatus;
  collections: ApiBaseCollectionJSON[];
}

export const selectMyCollections = createAppSelector(
  [
    (state) => state.meta.get('me') as string,
    (state) => state.collections.accountCollections,
    (state) => state.collections.collections,
  ],
  (me, collectionsByAccountId, collectionsById) => {
    const myCollectionsQuery = collectionsByAccountId[me];

    if (!myCollectionsQuery) {
      return {
        status: 'error',
        collections: [] as ApiBaseCollectionJSON[],
      } satisfies AccountCollectionQuery;
    }

    const { status, collectionIds } = myCollectionsQuery;

    return {
      status,
      collections: collectionIds
        .map((id) => collectionsById[id])
        .filter((c) => !!c),
    } satisfies AccountCollectionQuery;
  },
);
