import { useCallback, useEffect } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { fetchBlocks, expandBlocks } from '@/mastodon/actions/blocks';
import { Account } from '@/mastodon/components/account';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import ScrollableList from '@/mastodon/components/scrollable_list';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const AccountBlocks: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const accountIds = useAppSelector(
    (state) => state.user_lists.getIn(['blocks', 'items']) as string[] | null,
  );
  const hasMore = useAppSelector(
    (state) => !!state.user_lists.getIn(['blocks', 'next']),
  );
  const isLoading = useAppSelector(
    (state) => state.user_lists.getIn(['blocks', 'isLoading']) as boolean,
  );

  useEffect(() => {
    dispatch(fetchBlocks());
  }, [dispatch]);

  const handleLoadMore = useCallback(() => {
    dispatch(expandBlocks());
  }, [dispatch]);

  if (!accountIds) {
    return <LoadingIndicator />;
  }

  return (
    <>
      <ScrollableList
        scrollKey='blocks'
        onLoadMore={handleLoadMore}
        hasMore={hasMore}
        isLoading={isLoading}
        emptyMessage={
          <FormattedMessage
            id='empty_column.blocks'
            defaultMessage="You haven't blocked any accounts yet."
          />
        }
        bindToDocument={!multiColumn}
      >
        {accountIds.map((id) => (
          <Account key={id} id={id} defaultAction='block' />
        ))}
      </ScrollableList>
      <Helmet>
        <title>
          {intl.formatMessage({
            id: 'column.blocked_accounts',
            defaultMessage: 'Blocked Accounts',
          })}
        </title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountBlocks;
