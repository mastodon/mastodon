import type { FC } from 'react';

import { useCustomEmojis } from '@/mastodon/hooks/useCustomEmojis';

import { Emoji } from './emoji';

interface LegacyEmoji {
  id: string;
  custom?: boolean;
  native?: string;
  imageUrl?: string;
}

export const AutosuggestEmoji: FC<{ emoji: LegacyEmoji }> = ({ emoji }) => {
  const emojis = useCustomEmojis();
  const colons = `:${emoji.id}:`;
  return (
    <div className='autosuggest-emoji'>
      <Emoji code={emoji.native ?? colons} customEmoji={emojis} />
      <div className='autosuggest-emoji__name'>{colons}</div>
    </div>
  );
};
