import type { FC } from 'react';

import type { ApiAnnouncementReactionJSON } from '@/mastodon/api_types/announcements';

export const ReactionsBar: FC<{
  reactions: ApiAnnouncementReactionJSON[];
  id: string;
}> = () => {
  return null;
};
