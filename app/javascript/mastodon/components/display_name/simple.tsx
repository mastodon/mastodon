import type { ComponentPropsWithoutRef, FC } from 'react';

import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { EmojiHTML } from '../emoji/html';

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
      <EmojiHTML
        {...props}
        as='span'
        htmlString={
          isModernEmojiEnabled()
            ? account.get('display_name')
            : account.get('display_name_html')
        }
        extraEmojis={account.get('emojis')}
      />
    </bdi>
  );
};
