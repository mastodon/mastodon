import type { ComponentPropsWithoutRef, FC } from 'react';

import { EmojiHTML } from '@/mastodon/features/emoji/emoji_html';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

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
      <EmojiHTML {...props} htmlString={accountName} shallow as='span' />
    </bdi>
  );
};
