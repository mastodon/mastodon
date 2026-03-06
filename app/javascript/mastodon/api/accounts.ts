import {
  apiRequestPost,
  apiRequestGet,
  apiRequestDelete,
  apiRequestPatch,
} from 'mastodon/api';
import type {
  ApiAccountJSON,
  ApiFamiliarFollowersJSON,
} from 'mastodon/api_types/accounts';
import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';
import type {
  ApiFeaturedTagJSON,
  ApiHashtagJSON,
} from 'mastodon/api_types/tags';

import type {
  ApiProfileJSON,
  ApiProfileUpdateParams,
} from '../api_types/profile';

export const apiSubmitAccountNote = (id: string, value: string) =>
  apiRequestPost<ApiRelationshipJSON>(`v1/accounts/${id}/note`, {
    comment: value,
  });

export const apiFollowAccount = (
  id: string,
  params?: {
    reblogs: boolean;
  },
) =>
  apiRequestPost<ApiRelationshipJSON>(`v1/accounts/${id}/follow`, {
    ...params,
  });

export const apiUnfollowAccount = (id: string) =>
  apiRequestPost<ApiRelationshipJSON>(`v1/accounts/${id}/unfollow`);

export const apiRemoveAccountFromFollowers = (id: string) =>
  apiRequestPost<ApiRelationshipJSON>(
    `v1/accounts/${id}/remove_from_followers`,
  );

export const apiGetFeaturedTags = (id: string) =>
  apiRequestGet<ApiHashtagJSON[]>(`v1/accounts/${id}/featured_tags`);

export const apiGetCurrentFeaturedTags = () =>
  apiRequestGet<ApiFeaturedTagJSON[]>(`v1/featured_tags`);

export const apiPostFeaturedTag = (name: string) =>
  apiRequestPost<ApiFeaturedTagJSON>('v1/featured_tags', { name });

export const apiDeleteFeaturedTag = (id: string) =>
  apiRequestDelete(`v1/featured_tags/${id}`);

export const apiGetTagSuggestions = () =>
  apiRequestGet<ApiHashtagJSON[]>('v1/featured_tags/suggestions');

export const apiGetEndorsedAccounts = (id: string) =>
  apiRequestGet<ApiAccountJSON>(`v1/accounts/${id}/endorsements`);

export const apiGetFamiliarFollowers = (id: string) =>
  apiRequestGet<ApiFamiliarFollowersJSON>('v1/accounts/familiar_followers', {
    id,
  });

export const apiGetProfile = () => apiRequestGet<ApiProfileJSON>('v1/profile');

export const apiPatchProfile = (params: ApiProfileUpdateParams) =>
  apiRequestPatch<ApiProfileJSON>('v1/profile', params);
