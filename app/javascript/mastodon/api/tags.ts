import api, { getLinks, apiRequestPost, apiRequestGet } from 'mastodon/api';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';

export const apiGetTag = (tagId: string) =>
  apiRequestGet<ApiHashtagJSON>(`v1/tags/${tagId}`);

export const apiFollowTag = (tagId: string) =>
  apiRequestPost<ApiHashtagJSON>(`v1/tags/${tagId}/follow`);

export const apiUnfollowTag = (tagId: string) =>
  apiRequestPost<ApiHashtagJSON>(`v1/tags/${tagId}/unfollow`);

export const apiFeatureTag = (tagId: string) =>
  apiRequestPost<ApiHashtagJSON>(`v1/tags/${tagId}/feature`);

export const apiUnfeatureTag = (tagId: string) =>
  apiRequestPost<ApiHashtagJSON>(`v1/tags/${tagId}/unfeature`);

export const apiGetFollowedTags = async (url?: string, limit?: number) => {
  const response = await api().request<ApiHashtagJSON[]>({
    method: 'GET',
    url: url ?? '/api/v1/followed_tags',
    params: { limit },
  });

  return {
    tags: response.data,
    links: getLinks(response),
  };
};
