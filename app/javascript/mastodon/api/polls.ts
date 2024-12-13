import { apiRequestGet, apiRequestPost } from 'mastodon/api';
import type { ApiPollJSON } from 'mastodon/api_types/polls';

export const apiGetPoll = (pollId: string) =>
  apiRequestGet<ApiPollJSON>(`/v1/polls/${pollId}`);

export const apiPollVote = (pollId: string, choices: string[]) =>
  apiRequestPost<ApiPollJSON>(`/v1/polls/${pollId}/votes`, {
    choices,
  });
