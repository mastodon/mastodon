import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { fetchServer } from '@/mastodon/actions/server';
import { Button } from '@/mastodon/components/button/redesign';
import { Skeleton } from '@/mastodon/components/skeleton';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './logged_out_info.module.scss';

export const LoggedOutInfo: React.FC = () => {
  const dispatch = useAppDispatch();
  const { item: serverItem, isLoading } = useAppSelector(
    (state) => state.server.server,
  );

  useEffect(() => {
    void dispatch(fetchServer());
  }, [dispatch]);

  return (
    <>
      <p className={classes.description}>
        {isLoading ? (
          <>
            <Skeleton width='100%' />
            <br />
            <Skeleton width='100%' />
            <br />
            <Skeleton width='70%' />
          </>
        ) : (
          serverItem?.description
        )}
      </p>
      <div className={classes.buttons}>
        <Button as='a' href='/auth/sign_up' variant='solid'>
          <FormattedMessage
            id='server_banner.create_account'
            defaultMessage='Create an account'
          />
        </Button>
        <Button as='a' href='/auth/sign_in'>
          <FormattedMessage id='server_banner.log_in' defaultMessage='Log in' />
        </Button>
      </div>
    </>
  );
};
