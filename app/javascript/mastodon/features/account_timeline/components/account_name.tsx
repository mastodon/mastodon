import type { FC } from 'react';

import { useIntl } from 'react-intl';

import { DisplayName } from '@/mastodon/components/display_name';
import { Icon } from '@/mastodon/components/icon';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAppSelector } from '@/mastodon/store';
import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';

import { DomainPill } from '../../account/components/domain_pill';
import { isRedesignEnabled } from '../common';

import classes from './redesign.module.scss';

export const AccountName: FC<{ accountId: string; className?: string }> = ({
  accountId,
  className,
}) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const me = useAppSelector((state) => state.meta.get('me') as string);
  const localDomain = useAppSelector(
    (state) => state.meta.get('domain') as string,
  );

  if (!account) {
    return null;
  }

  const [username = '', domain = localDomain] = account.acct.split('@');

  return (
    <h1 className={className}>
      <DisplayName account={account} variant='simple' />
      <small>
        <span>
          @{username}
          {isRedesignEnabled() && '@'}
          <span className='invisible'>
            {!isRedesignEnabled() && '@'}
            {domain}
          </span>
        </span>
        <DomainPill
          username={username}
          domain={domain}
          isSelf={me === account.id}
          className={(isRedesignEnabled() && classes.domainPill) || ''}
        >
          {isRedesignEnabled() && <Icon id='info' icon={InfoIcon} />}
        </DomainPill>
        {!isRedesignEnabled() && account.locked && (
          <Icon
            id='lock'
            icon={LockIcon}
            aria-label={intl.formatMessage({
              id: 'account.locked_info',
              defaultMessage:
                'This account privacy status is set to locked. The owner manually reviews who can follow them.',
            })}
          />
        )}
      </small>
    </h1>
  );
};
