import type { FC } from 'react';

import { useCustomEmojis } from '@/mastodon/hooks/useCustomEmojis';

import { Emoji } from './emoji';

interface LegacyEmoji {
  colons: string;
  custom?: boolean;
  native?: string;
  imageUrl?: string;
}

export const AutosuggestEmoji: FC<{ emoji: LegacyEmoji }> = ({ emoji }) => {
  const emojis = useCustomEmojis();
  return (
    <div className='autosuggest-emoji'>
      <Emoji code={emoji.native ?? emoji.colons} customEmoji={emojis} />
      <div className='autosuggest-emoji__name'>{emoji.colons}</div>
    </div>
  );
};
