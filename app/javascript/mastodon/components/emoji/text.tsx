import { useMemo } from 'react';
import type { FC } from 'react';

import type { CustomEmojiMapArg } from '@/mastodon/features/emoji/types';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { CustomEmojiProvider } from './context';
import { textToEmojis } from './index';

interface EmojiTextProps {
  text: string;
  extraEmojis?: CustomEmojiMapArg;
}

export const ModernEmojiText: FC<EmojiTextProps> = ({ text, extraEmojis }) => {
  const contents = useMemo(() => textToEmojis(text), [text]);

  return (
    <CustomEmojiProvider emojis={extraEmojis}>{contents}</CustomEmojiProvider>
  );
};

export const EmojiText: FC<EmojiTextProps> = ({ text }) =>
  isModernEmojiEnabled() ? <ModernEmojiText text={text} /> : text;
