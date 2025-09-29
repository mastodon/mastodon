import type { ComponentPropsWithoutRef, FC } from 'react';

import classNames from 'classnames';

import { EmojiText } from '@/mastodon/components/emoji/text';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { AnimateEmojiProvider } from '../emoji/context';
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
          <strong className='display-name__html'>
            <EmojiText
              text={
                isModernEmojiEnabled()
                  ? account.get('display_name')
                  : account.get('display_name_html')
              }
              extraEmojis={account.get('emojis')}
            />
          </strong>
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
