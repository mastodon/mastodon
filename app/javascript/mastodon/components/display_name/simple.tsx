import type { ComponentPropsWithoutRef, FC } from 'react';

import { ModernEmojiText } from '@/mastodon/features/emoji/emoji_text';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { AnimateEmojiProvider } from '../emoji/context';

import type { DisplayNameProps } from './index';

export const DisplayNameSimple: FC<
  Omit<DisplayNameProps, 'variant' | 'localDomain'> &
    ComponentPropsWithoutRef<'span'>
> = ({ account, ...props }) => {
  if (!account) {
    return null;
  }
  const accountName = isModernEmojiEnabled()
    ? account.get('display_name')
    : account.get('display_name_html');
  return (
    <bdi>
      <AnimateEmojiProvider as='span' {...props}>
        <ModernEmojiText
          text={accountName}
          extraEmojis={account.get('emojis')}
        />
      </AnimateEmojiProvider>
    </bdi>
  );
};
