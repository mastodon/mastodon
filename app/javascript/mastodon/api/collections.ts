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
  ApiPatchCollectionPayload,
  ApiCollectionsJSON,
} from '../api_types/collections';

export const apiCreateCollection = (collection: ApiCreateCollectionPayload) =>
  apiRequestPost<ApiWrappedCollectionJSON>('v1_alpha/collections', collection);

export const apiUpdateCollection = ({
  id,
  ...collection
}: ApiPatchCollectionPayload) =>
  apiRequestPut<ApiWrappedCollectionJSON>(
    `v1_alpha/collections/${id}`,
    collection,
  );

export const apiDeleteCollection = (collectionId: string) =>
  apiRequestDelete(`v1_alpha/collections/${collectionId}`);

export const apiGetCollection = (collectionId: string) =>
  apiRequestGet<ApiCollectionWithAccountsJSON[]>(
    `v1_alpha/collections/${collectionId}`,
  );

export const apiGetAccountCollections = (accountId: string) =>
  apiRequestGet<ApiCollectionsJSON>(
    `v1_alpha/accounts/${accountId}/collections`,
  );
