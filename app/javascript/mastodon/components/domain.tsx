import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import LockOpenIcon from '@/material-icons/400-24px/lock_open.svg?react';

import { IconButton } from './icon_button';

const messages = defineMessages({
  unblockDomain: {
    id: 'account.unblock_domain',
    defaultMessage: 'Unblock domain {domain}',
  },
});

interface Props {
  domain: string;
  onUnblockDomain: (domain: string) => void;
}

export const Domain: React.FC<Props> = ({ domain, onUnblockDomain }) => {
  const intl = useIntl();

  const handleDomainUnblock = useCallback(() => {
    onUnblockDomain(domain);
  }, [domain, onUnblockDomain]);

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
