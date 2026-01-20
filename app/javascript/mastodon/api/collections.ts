import {
  apiRequestPost,
  apiRequestPut,
  apiRequestGet,
  apiRequestDelete,
} from 'mastodon/api';

import type {
  ApiFullCollectionJSON,
  ApiBaseCollectionJSON,
  ApiCreateCollectionPayload,
  ApiPatchCollectionPayload,
} from '../api_types/collections';

export const apiCreate = (collection: ApiCreateCollectionPayload) =>
  apiRequestPost<ApiFullCollectionJSON>('v1_alpha/collections', collection);

export const apiUpdate = ({ id, ...collection }: ApiPatchCollectionPayload) =>
  apiRequestPut<ApiFullCollectionJSON>(
    `v1_alpha/collections/${id}`,
    collection,
  );

export const apiDelete = (collectionId: string) =>
  apiRequestDelete(`v1_alpha/collections/${collectionId}`);

export const apiGetCollection = (collectionId: string) =>
  apiRequestGet<ApiFullCollectionJSON[]>(
    `v1_alpha/collections/${collectionId}`,
  );

export const apiGetAccountCollections = (accountId: string) =>
  apiRequestGet<ApiBaseCollectionJSON[]>(
    `v1_alpha/accounts/${accountId}/collections`,
  );
