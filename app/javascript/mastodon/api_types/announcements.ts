// See app/serializers/rest/announcement_serializer.rb

import type { ApiCustomEmojiJSON } from './custom_emoji';
import type { ApiMentionJSON, ApiStatusJSON, ApiTagJSON } from './statuses';

export interface ApiAnnouncementJSON {
  id: string;
  content: string;
  starts_at: null | string;
  ends_at: null | string;
  all_day: boolean;
  published_at: string;
  updated_at: null | string;
  read: boolean;
  mentions: ApiMentionJSON[];
  statuses: ApiStatusJSON[];
  tags: ApiTagJSON[];
  emojis: ApiCustomEmojiJSON[];
  reactions: ApiAnnouncementReactionJSON[];
}

export interface ApiAnnouncementReactionJSON {
  name: string;
  count: number;
  me: boolean;
  url?: string;
  static_url?: string;
}
