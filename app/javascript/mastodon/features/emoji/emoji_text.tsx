import { useMemo } from 'react';
import type { FC } from 'react';

import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { onText } from './emoji_html';
import { cleanExtraEmojis } from './normalize';
import type { CustomEmojiMapArg } from './types';

interface EmojiTextProps {
  text: string;
  extraEmojis?: CustomEmojiMapArg;
}

export const ModernEmojiText: FC<EmojiTextProps> = ({
  text,
  extraEmojis: rawExtraEmojis,
}) => {
  const contents = useMemo(() => onText(text), [text]);
  const extraEmojis = useMemo(
    () => cleanExtraEmojis(rawExtraEmojis),
    [rawExtraEmojis],
  );

  return (
    <CustomEmojiProvider emoji={extraEmojis}>{contents}</CustomEmojiProvider>
  );
};

export const EmojiText: FC<EmojiTextProps> = ({ text }) =>
  isModernEmojiEnabled() ? <ModernEmojiText text={text} /> : text;
