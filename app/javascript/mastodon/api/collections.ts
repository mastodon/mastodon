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
  apiRequestPost<ApiWrappedCollectionJSON>('v1/collections', collection);

export const apiUpdateCollection = ({
  id,
  ...collection
}: ApiUpdateCollectionPayload) =>
  apiRequestPut<ApiWrappedCollectionJSON>(`v1/collections/${id}`, collection);

export const apiDeleteCollection = (collectionId: string) =>
  apiRequestDelete(`v1/collections/${collectionId}`);

export const apiGetCollection = (collectionId: string) =>
  apiRequestGet<ApiCollectionWithAccountsJSON>(
    `v1/collections/${collectionId}`,
  );

export const apiGetCollectionsCreatedByAccount = (accountId: string) =>
  apiRequestGet<ApiCollectionsJSON>(`v1/accounts/${accountId}/collections`);

export const apiGetCollectionsFeaturingAccount = (accountId: string) =>
  apiRequestGet<ApiCollectionsJSON>(`v1/accounts/${accountId}/in_collections`);

export const apiAddCollectionItem = (collectionId: string, accountId: string) =>
  apiRequestPost<WrappedCollectionAccountItem>(
    `v1/collections/${collectionId}/items`,
    { account_id: accountId },
  );

export const apiRemoveCollectionItem = (collectionId: string, itemId: string) =>
  apiRequestDelete<WrappedCollectionAccountItem>(
    `v1/collections/${collectionId}/items/${itemId}`,
  );

export const apiRevokeCollectionInclusion = (
  collectionId: string,
  itemId: string,
) => apiRequestPost(`v1/collections/${collectionId}/items/${itemId}/revoke`);
