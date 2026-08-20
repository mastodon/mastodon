import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { unblockDomain } from 'mastodon/actions/domain_blocks';
import { useAppDispatch } from 'mastodon/store';

import { Button } from './button';

export const Domain: React.FC<{
  domain: string;
  onUnblock?: (domain: string) => void;
}> = ({ domain, onUnblock }) => {
  const dispatch = useAppDispatch();

  const handleDomainUnblock = useCallback(() => {
    dispatch(unblockDomain(domain));
    onUnblock?.(domain);
  }, [dispatch, domain, onUnblock]);

  return (
    <div className='domain'>
      <div className='domain__domain-name'>
        <strong>{domain}</strong>
      </div>

      <div className='domain__buttons'>
        <Button onClick={handleDomainUnblock}>
          <FormattedMessage
            id='account.unblock_domain_short'
            defaultMessage='Unblock'
          />
        </Button>
      </div>
    </div>
  );
};
