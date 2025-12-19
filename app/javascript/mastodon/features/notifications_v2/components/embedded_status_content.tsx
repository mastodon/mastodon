import { useCallback, useMemo } from 'react';

import type { List } from 'immutable';

import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import type { CustomEmoji } from '@/mastodon/models/custom_emoji';
import type { Status } from '@/mastodon/models/status';

import type { Mention } from './embedded_status';

export const EmbeddedStatusContent: React.FC<{
  status: Status;
  className?: string;
}> = ({ status, className }) => {
  const mentions = useMemo(
    () => (status.get('mentions') as List<Mention>).toJS(),
    [status],
  );
  const hrefToMention = useCallback(
    (href: string) => {
      return mentions.find((item) => item.url === href);
    },
    [mentions],
  );
  const htmlHandlers = useElementHandledLink({
    hashtagAccountId: status.get('account') as string | undefined,
    hrefToMention,
  });

  return (
    <EmojiHTML
      {...htmlHandlers}
      className={className}
      lang={status.get('language') as string}
      htmlString={status.get('contentHtml') as string}
      extraEmojis={status.get('emojis') as List<CustomEmoji>}
    />
  );
};
