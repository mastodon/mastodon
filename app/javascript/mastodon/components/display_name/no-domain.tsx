import type { ComponentPropsWithoutRef, FC } from 'react';

import classNames from 'classnames';

import { AnimateEmojiProvider } from '../emoji/context';
import { EmojiHTML } from '../emoji/html';
import { Skeleton } from '../skeleton';

import type { DisplayNameProps } from './index';

export const DisplayNameWithoutDomain: FC<
  Omit<DisplayNameProps, 'variant' | 'localDomain'> &
    ComponentPropsWithoutRef<'span'>
> = ({ account, className, children, ...props }) => {
  return (
    <AnimateEmojiProvider
      {...props}
      as='span'
      className={classNames('display-name', className)}
    >
      <bdi>
        {account ? (
          <EmojiHTML
            className='display-name__html'
            htmlString={account.get('display_name_html')}
            as='strong'
            extraEmojis={account.get('emojis')}
          />
        ) : (
          <strong className='display-name__html'>
            <Skeleton width='10ch' />
          </strong>
        )}
      </bdi>
      {children}
    </AnimateEmojiProvider>
  );
};
