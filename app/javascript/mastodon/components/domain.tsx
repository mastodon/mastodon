import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import LockOpenIcon from '@/material-icons/400-24px/lock_open.svg?react';
import { unblockDomain } from 'mastodon/actions/domain_blocks';
import { useAppDispatch } from 'mastodon/store';

import { IconButton } from './icon_button';

const messages = defineMessages({
  unblockDomain: {
    id: 'account.unblock_domain',
    defaultMessage: 'Unblock domain {domain}',
  },
});

export const Domain: React.FC<{
  domain: string;
}> = ({ domain }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const handleDomainUnblock = useCallback(() => {
    dispatch(unblockDomain(domain));
  }, [dispatch, domain]);

  return (
    <div className='domain'>
      <div className='domain__wrapper'>
        <span className='domain__domain-name'>
          <strong>{domain}</strong>
        </span>

        <div className='domain__buttons'>
          <IconButton
            active
            icon='unlock'
            iconComponent={LockOpenIcon}
            title={intl.formatMessage(messages.unblockDomain, { domain })}
            onClick={handleDomainUnblock}
          />
        </div>
      </div>
    </div>
  );
};
