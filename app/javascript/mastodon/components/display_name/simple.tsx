import type { ComponentPropsWithoutRef, FC } from 'react';

import { HTMLBlock } from '../html_contents/html_block';

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
      <HTMLBlock
        {...props}
        contents={account.get('display_name')}
        extraEmojis={account.get('emojis')}
      />
    </bdi>
  );
};
