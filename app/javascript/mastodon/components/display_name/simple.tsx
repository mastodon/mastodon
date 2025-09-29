import type { ComponentPropsWithoutRef, FC } from 'react';

import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { AnimateEmojiProvider } from '../emoji/context';
import { EmojiText } from '../emoji/text';

import type { DisplayNameProps } from './index';

export const DisplayNameSimple: FC<
  Omit<DisplayNameProps, 'variant' | 'localDomain'> &
    ComponentPropsWithoutRef<'span'>
> = ({ account, ...props }) => {
  if (!account) {
    return null;
  }

  return (
    <bdi>
      <AnimateEmojiProvider as='span' {...props}>
        <EmojiText
          text={
            isModernEmojiEnabled()
              ? account.get('display_name')
              : account.get('display_name_html')
          }
          extraEmojis={account.get('emojis')}
        />
      </AnimateEmojiProvider>
    </bdi>
  );
};
