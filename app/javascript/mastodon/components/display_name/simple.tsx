import type { ComponentPropsWithoutRef, FC } from 'react';

import { EmojiHTML } from '../emoji/html';

import type { DisplayNameProps } from './index';

export const DisplayNameSimple: FC<
  Omit<DisplayNameProps, 'variant'> & ComponentPropsWithoutRef<'span'>
> = ({ account, localDomain: _, ...props }) => {
  if (!account) {
    return null;
  }

  return (
    <bdi>
      <EmojiHTML
        {...props}
        as='span'
        htmlString={account.get('display_name_html')}
        extraEmojis={account.get('emojis')}
      />
    </bdi>
  );
};
