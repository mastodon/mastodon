import type { FC, ReactNode } from 'react';

import { useCustomEmojis } from '@/mastodon/hooks/useCustomEmojis';

import { Emoji } from './emoji';
import { CustomEmojiProvider } from './emoji/context';

interface LegacyEmoji {
  id: string;
  custom?: boolean;
  native?: string;
  imageUrl?: string;
}

export const AutosuggestEmoji: FC<{ emoji: LegacyEmoji }> = ({ emoji }) => {
  const colons = `:${emoji.id}:`;
  return (
    <div className='autosuggest-emoji'>
      <Emoji code={emoji.native ?? colons} />
      <div className='autosuggest-emoji__name'>{colons}</div>
    </div>
  );
};

export const AutosuggestEmojiContext: FC<{ children: ReactNode }> = ({
  children,
}) => {
  const emojis = useCustomEmojis();
  return <CustomEmojiProvider emojis={emojis}>{children}</CustomEmojiProvider>;
};
