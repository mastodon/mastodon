import { useCallback, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import { WarningIcon } from '@phosphor-icons/react';

import { openModal } from '@/mastodon/actions/modal';
import { fetchServer } from '@/mastodon/actions/server';
import { Button } from '@/mastodon/components/button/redesign';
import { Callout } from '@/mastodon/components/callout/redesign';
import { Skeleton } from '@/mastodon/components/skeleton';
import {
  disabledAccountId,
  domain,
  movedToAccountId,
} from '@/mastodon/initial_state';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './logged_out_info.module.scss';

const NavigationFooterLayout: React.FC<{
  isLoading?: boolean;
  description: React.ReactNode;
  children: React.ReactNode;
}> = ({ description, isLoading, children }) => (
  <>
    <div className={classes.description}>
      {isLoading ? (
        <>
          <Skeleton width='100%' />
          <br />
          <Skeleton width='100%' />
          <br />
          <Skeleton width='70%' />
        </>
      ) : (
        description
      )}
    </div>
    <div className={classes.buttons}>{children}</div>
  </>
);

export const LoggedOutInfo: React.FC = () => {
  const dispatch = useAppDispatch();
  const { item: serverItem, isLoading } = useAppSelector(
    (state) => state.server.server,
  );

  useEffect(() => {
    void dispatch(fetchServer());
  }, [dispatch]);

  return (
    <NavigationFooterLayout
      description={<p>{serverItem?.description ?? ''}</p>}
      isLoading={isLoading}
    >
      <Button as='a' href='/auth/sign_up' variant='solid'>
        <FormattedMessage
          id='server_banner.create_account'
          defaultMessage='Create an account'
        />
      </Button>
      <Button as='a' href='/auth/sign_in'>
        <FormattedMessage id='server_banner.log_in' defaultMessage='Log in' />
      </Button>
    </NavigationFooterLayout>
  );
};

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
    <NavigationFooterLayout
      description={
        <Callout icon={WarningIcon}>
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
        </Callout>
      }
    >
      <Button as='a' href='/auth/edit' variant='solid'>
        <FormattedMessage
          id='disabled_account_banner.account_settings'
          defaultMessage='Account settings'
        />
      </Button>
      <Button onClick={handleLogOutClick}>
        <FormattedMessage
          id='confirmations.logout.confirm'
          defaultMessage='Log out'
        />
      </Button>
    </NavigationFooterLayout>
  );
};
