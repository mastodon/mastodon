import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { fetchFeaturedTags } from 'mastodon/actions/featured_tags';
import { expandAccountFeaturedTimeline } from 'mastodon/actions/timelines';
import { ColumnBackButton } from 'mastodon/components/column_back_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { RemoteHint } from 'mastodon/components/remote_hint';
import StatusContainer from 'mastodon/containers/status_container';
import { useAccountId } from 'mastodon/hooks/useAccountId';
import { useAccountVisibility } from 'mastodon/hooks/useAccountVisibility';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { AccountHeader } from '../account_timeline/components/account_header';
import Column from '../ui/components/column';

import { EmptyMessage } from './components/empty_message';
import { FeaturedTags } from './components/featured_tags';

const AccountFeatured = () => {
  const accountId = useAccountId();
  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);
  const forceEmptyState = suspended || blockedBy || hidden;

  const dispatch = useAppDispatch();

  useEffect(() => {
    if (accountId) {
      void dispatch(expandAccountFeaturedTimeline(accountId));
      dispatch(fetchFeaturedTags(accountId));
    }
  }, [accountId, dispatch]);

  const isLoading = useAppSelector(
    (state) =>
      !accountId ||
      !!(state.timelines as ImmutableMap<string, unknown>).getIn([
        `account:${accountId}:pinned`,
        'isLoading',
      ]) ||
      !!state.user_lists.getIn(['featured_tags', accountId, 'isLoading']),
  );
  const featuredStatusIds = useAppSelector(
    (state) =>
      (state.timelines as ImmutableMap<string, unknown>).getIn(
        [`account:${accountId}:pinned`, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );

  return (
    <Column>
      <ColumnBackButton />

      <div className='scrollable scrollable--flex'>
        {accountId && (
          <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
        )}
        <FeaturedTags accountId={accountId} />
        {isLoading && (
          <div className='scrollable__append'>
            <LoadingIndicator />
          </div>
        )}
        {!featuredStatusIds.isEmpty() && !isLoading && (
          <>
            <h4 className='column-subheading'>
              <FormattedMessage
                id='account.featured.posts'
                defaultMessage='Posts'
              />
            </h4>
            {featuredStatusIds.map((statusId) => (
              <StatusContainer
                key={`f-${statusId}`}
                // @ts-expect-error inferred props are wrong
                id={statusId}
                contextType='account'
              />
            ))}
          </>
        )}
        {!isLoading && featuredStatusIds.isEmpty() && (
          <EmptyMessage
            blockedBy={blockedBy}
            hidden={hidden}
            suspended={suspended}
            accountId={accountId}
          />
        )}
        <RemoteHint accountId={accountId} />
      </div>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountFeatured;
