import {
  apiRequestPost,
  apiRequestPut,
  apiRequestGet,
  apiRequestDelete,
} from 'mastodon/api';

import type {
  ApiWrappedCollectionJSON,
  ApiCollectionWithAccountsJSON,
  ApiCreateCollectionPayload,
  ApiUpdateCollectionPayload,
  ApiCollectionsJSON,
  WrappedCollectionAccountItem,
} from '../api_types/collections';

export const apiCreateCollection = (collection: ApiCreateCollectionPayload) =>
  apiRequestPost<ApiWrappedCollectionJSON>('v1_alpha/collections', collection);

export const apiUpdateCollection = ({
  id,
  ...collection
}: ApiUpdateCollectionPayload) =>
  apiRequestPut<ApiWrappedCollectionJSON>(
    `v1_alpha/collections/${id}`,
    collection,
  );

export const apiDeleteCollection = (collectionId: string) =>
  apiRequestDelete(`v1_alpha/collections/${collectionId}`);

export const apiGetCollection = (collectionId: string) =>
  apiRequestGet<ApiCollectionWithAccountsJSON>(
    `v1_alpha/collections/${collectionId}`,
  );

export const apiGetAccountCollections = (accountId: string) =>
  apiRequestGet<ApiCollectionsJSON>(
    `v1_alpha/accounts/${accountId}/collections`,
  );

export const apiAddCollectionItem = (collectionId: string, accountId: string) =>
  apiRequestPost<WrappedCollectionAccountItem>(
    `v1_alpha/collections/${collectionId}/items`,
    { account_id: accountId },
  );

export const apiRemoveCollectionItem = (collectionId: string, itemId: string) =>
  apiRequestDelete<WrappedCollectionAccountItem>(
    `v1_alpha/collections/${collectionId}/items/${itemId}`,
  );
