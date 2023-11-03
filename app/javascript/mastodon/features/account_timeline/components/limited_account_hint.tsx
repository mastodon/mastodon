import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { revealAccount } from 'mastodon/actions/accounts_typed';
import { Button } from 'mastodon/components/button';
import { domain } from 'mastodon/initial_state';
import { useAppDispatch } from 'mastodon/store';

export const LimitedAccountHint: React.FC<{ accountId: string }> = ({
  accountId,
}) => {
  const dispatch = useAppDispatch();
  const reveal = useCallback(() => {
    dispatch(revealAccount({ id: accountId }));
  }, [dispatch, accountId]);

  return (
    <div className='limited-account-hint'>
      <p>
        <FormattedMessage
          id='limited_account_hint.title'
          defaultMessage='This profile has been hidden by the moderators of {domain}.'
          values={{ domain }}
        />
      </p>
      <Button onClick={reveal}>
        <FormattedMessage
          id='limited_account_hint.action'
          defaultMessage='Show profile anyway'
        />
      </Button>
    </div>
  );
};
