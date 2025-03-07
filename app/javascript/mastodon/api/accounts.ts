import { apiRequestPost, apiRequestGet } from 'mastodon/api';
import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type { ApiRelationshipJSON } from 'mastodon/api_types/relationships';

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

export const apiLookupAccount = (acct: string) =>
  apiRequestGet<ApiAccountJSON>('v1/accounts/lookup', { acct });
