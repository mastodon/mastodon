import type { ComponentPropsWithoutRef, FC } from 'react';

import classNames from 'classnames';

import { HTMLBlock } from '../html_contents/html_block';
import { Skeleton } from '../skeleton';

import type { DisplayNameProps } from './index';

export const DisplayNameWithoutDomain: FC<
  Omit<DisplayNameProps, 'variant' | 'localDomain'> &
    ComponentPropsWithoutRef<'span'>
> = ({ account, className, children, ...props }) => {
  return (
    <span {...props} className={classNames('display-name', className)}>
      <bdi>
        {account ? (
          <strong className='display-name__html'>
            <HTMLBlock
              contents={account.get('display_name')}
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
    </span>
  );
};
