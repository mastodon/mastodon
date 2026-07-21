import type { StatusVisibility } from '@/mastodon/models/status';
import { createAppSelector } from '@/mastodon/store';

export type ComposeType = 'post' | 'message' | 'reply';

export const selectComposeType = createAppSelector(
  [
    (state) => state.compose.get('in_reply_to') as string | null,
    (state) =>
      (state.compose.get('privacy') as StatusVisibility | null) ??
      (state.compose.get('default_privacy') as StatusVisibility),
  ],
  (inReplyToId, privacy) => {
    let type: ComposeType = 'post';
    if (inReplyToId) {
      type = 'reply';
    } else if (privacy === 'direct') {
      type = 'message';
    }

    return type;
  },
);
