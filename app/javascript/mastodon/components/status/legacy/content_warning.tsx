import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { useStatus } from '@/mastodon/hooks/useStatus';

import { StatusBanner, BannerVariant } from './banner';

export const ContentWarning: React.FC<{
  statusId: string;
  expanded?: boolean;
  onClick?: () => void;
}> = ({ statusId, expanded, onClick }) => {
  const status = useStatus(statusId);
  const hasSpoiler = !!status?.spoiler_text;
  const text = status?.translation?.spoilerHtml ?? status?.spoilerHtml;
  if (!hasSpoiler || !text) {
    return null;
  }

  return (
    <StatusBanner
      expanded={expanded}
      onClick={onClick}
      variant={BannerVariant.Warning}
    >
      <EmojiHTML as='span' htmlString={text} extraEmojis={status.emojis} />
    </StatusBanner>
  );
};
