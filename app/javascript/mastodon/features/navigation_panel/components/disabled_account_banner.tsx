import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { openModal } from 'mastodon/actions/modal';
import {
  disabledAccountId,
  movedToAccountId,
  domain,
} from 'mastodon/initial_state';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

export const DisabledAccountBanner: React.FC = () => {
  const disabledAccount = useAppSelector((state) =>
    disabledAccountId ? state.accounts.get(disabledAccountId) : undefined,
  );
  const movedToAccount = useAppSelector((state) =>
    movedToAccountId ? state.accounts.get(movedToAccountId) : undefined,
  );
  const dispatch = useAppDispatch();

  const handleLogOutClick = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();

      dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT', modalProps: {} }));

      return false;
    },
    [dispatch],
  );

  const disabledAccountLink = (
    <Link to={`/@${disabledAccount?.acct}`}>
      {disabledAccount?.acct}@{domain}
    </Link>
  );

  return (
    <div className='sign-in-banner'>
      <p>
        {movedToAccount ? (
          <FormattedMessage
            id='moved_to_account_banner.text'
            defaultMessage='Your account {disabledAccount} is currently disabled because you moved to {movedToAccount}.'
            values={{
              disabledAccount: disabledAccountLink,
              movedToAccount: (
                <Link to={`/@${movedToAccount.acct}`}>
                  {movedToAccount.acct.includes('@')
                    ? movedToAccount.acct
                    : `${movedToAccount.acct}@${domain}`}
                </Link>
              ),
            }}
          />
        ) : (
          <FormattedMessage
            id='disabled_account_banner.text'
            defaultMessage='Your account {disabledAccount} is currently disabled.'
            values={{
              disabledAccount: disabledAccountLink,
            }}
          />
        )}
      </p>
      <a href='/auth/edit' className='button button--block'>
        <FormattedMessage
          id='disabled_account_banner.account_settings'
          defaultMessage='Account settings'
        />
      </a>
      <button
        type='button'
        className='button button--block button-secondary'
        onClick={handleLogOutClick}
      >
        <FormattedMessage
          id='confirmations.logout.confirm'
          defaultMessage='Log out'
        />
      </button>
    </div>
  );
};
