import { useMemo } from 'react';
import type { ComponentPropsWithoutRef, FC } from 'react';

import { Skeleton } from '../skeleton';

import type { DisplayNameProps } from './index';
import { DisplayNameWithoutDomain } from './no-domain';

export const DisplayNameDefault: FC<
  Omit<DisplayNameProps, 'variant'> & {
    oneLine?: boolean;
  } & ComponentPropsWithoutRef<'span'>
> = ({ account, oneLine = false, localDomain, className, ...props }) => {
  const username = useMemo(() => {
    if (!account) {
      return null;
    }
    let acct = account.get('acct');

    if (!acct.includes('@') && localDomain) {
      acct = `${acct}@${localDomain}`;
    }
    return `@${acct}`;
  }, [account, localDomain]);

  return (
    <DisplayNameWithoutDomain
      account={account}
      className={className}
      {...props}
    >
      <span className='display-name__account'>
        {oneLine && <>&nbsp;</>}
        {username ?? <Skeleton width='7ch' />}
      </span>
    </DisplayNameWithoutDomain>
  );
};
