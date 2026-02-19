import type { ApiCustomEmojiJSON } from './custom_emoji';

// See app/serializers/rest/poll_serializer.rb

export interface ApiPollOptionJSON {
  title: string;
  votes_count: number;
}

export interface ApiPollJSON {
  id: string;
  expires_at: string;
  expired: boolean;
  multiple: boolean;
  votes_count: number;
  voters_count: number | null;

  options: ApiPollOptionJSON[];
  emojis: ApiCustomEmojiJSON[];

  voted?: boolean;
  own_votes?: number[];
}
