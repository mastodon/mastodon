import type { ComponentPropsWithoutRef, FC } from 'react';

import classNames from 'classnames';

import { EmojiHTML } from '@/mastodon/features/emoji/emoji_html';
import { isModernEmojiEnabled } from '@/mastodon/utils/environment';

import { Skeleton } from '../skeleton';

import type { DisplayNameProps } from './index';

export const DisplayNameWithoutDomain: FC<
  Omit<DisplayNameProps, 'variant' | 'localDomain'> &
    ComponentPropsWithoutRef<'span'>
> = ({ account, className, children, ...props }) => {
  return (
    <span
      {...props}
      className={classNames('display-name animate-parent', className)}
    >
      <bdi>
        {account ? (
          <EmojiHTML
            className='display-name__html'
            htmlString={
              isModernEmojiEnabled()
                ? account.get('display_name')
                : account.get('display_name_html')
            }
            shallow
            as='strong'
          />
        ) : (
          <strong className='display-name__html'>
            <Skeleton width='10ch' />
          </strong>
        )}
      </bdi>
      {children}
    </span>
  );
};
