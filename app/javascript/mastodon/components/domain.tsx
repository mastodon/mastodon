import React, { useCallback } from 'react';
import { IconButton } from './icon_button';
import type { InjectedIntl } from 'react-intl';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  unblockDomain: {
    id: 'account.unblock_domain',
    defaultMessage: 'Unblock domain {domain}',
  },
});

interface Props {
  domain: string;
  onUnblockDomain: (domain: string) => void;
  intl: InjectedIntl;
}
const _Domain: React.FC<Props> = ({ domain, onUnblockDomain, intl }) => {
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
            title={intl.formatMessage(messages.unblockDomain, { domain })}
            onClick={handleDomainUnblock}
          />
        </div>
      </div>
    </div>
  );
};

export const Domain = injectIntl(_Domain);
