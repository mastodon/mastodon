import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { fetchExtendedDescription } from 'mastodon/actions/server';
import { Account } from 'mastodon/components/account';
import { Skeleton } from 'mastodon/components/skeleton';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import classes from './styles.module.scss';

const Placeholder = () => (
  <div className={classes.placeholder}>
    <Skeleton width='100%' />
    <Skeleton width='100%' />
    <Skeleton width='100%' />
  </div>
);

export const About = () => {
  const dispatch = useAppDispatch();
  const server = useAppSelector((state) => state.server.server);
  const extendedDescription = useAppSelector(
    (state) => state.server.extendedDescription,
  );

  const accountId = server.item?.contact.account?.id ?? '';
  const isLoading = extendedDescription.isLoading;
  const hasContent = (extendedDescription.item?.content.length ?? 0) > 0;
  const content = extendedDescription.item?.content ?? '';

  useEffect(() => {
    void dispatch(fetchExtendedDescription());
  }, [dispatch]);

  return (
    <>
      <div className={classes.block}>
        <h2>
          <FormattedMessage
            id='custom_homepage.administered_by'
            defaultMessage='Administered by'
          />
        </h2>
        <Account id={accountId} size={36} minimal />
      </div>

      <div className={classes.block}>
        <h2>
          <FormattedMessage
            id='custom_homepage.about_this_server'
            defaultMessage='About this server'
          />
        </h2>
        {isLoading ? (
          <Placeholder />
        ) : hasContent ? (
          <div
            className='prose'
            dangerouslySetInnerHTML={{ __html: content }}
          />
        ) : (
          <div className='prose'>
            <p>
              <FormattedMessage
                id='about.not_available'
                defaultMessage='This information has not been made available on this server.'
              />
            </p>
          </div>
        )}
      </div>
    </>
  );
};
