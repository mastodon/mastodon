import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';

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
import { FeaturedTag } from './components/featured_tag';
import type { TagMap } from './components/featured_tag';

interface Params {
  acct?: string;
  id?: string;
}

const AccountFeatured = () => {
  const accountId = useAccountId();
  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);
  const forceEmptyState = suspended || blockedBy || hidden;
  const { acct = '' } = useParams<Params>();

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
  const featuredTags = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['featured_tags', accountId, 'items'],
        ImmutableList(),
      ) as ImmutableList<TagMap>,
  );
  const featuredStatusIds = useAppSelector(
    (state) =>
      (state.timelines as ImmutableMap<string, unknown>).getIn(
        [`account:${accountId}:pinned`, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );

  if (isLoading) {
    return (
      <AccountFeaturedWrapper accountId={accountId}>
        <div className='scrollable__append'>
          <LoadingIndicator />
        </div>
      </AccountFeaturedWrapper>
    );
  }

  if (featuredStatusIds.isEmpty() && featuredTags.isEmpty()) {
    return (
      <AccountFeaturedWrapper accountId={accountId}>
        <EmptyMessage
          blockedBy={blockedBy}
          hidden={hidden}
          suspended={suspended}
          accountId={accountId}
        />
        <RemoteHint accountId={accountId} />
      </AccountFeaturedWrapper>
    );
  }

  return (
    <Column>
      <ColumnBackButton />

      <div className='scrollable scrollable--flex'>
        {accountId && (
          <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
        )}
        {!featuredTags.isEmpty() && (
          <>
            <h4 className='column-subheading'>
              <FormattedMessage
                id='account.featured.hashtags'
                defaultMessage='Hashtags'
              />
            </h4>
            {featuredTags.map((tag) => (
              <FeaturedTag key={tag.get('id')} tag={tag} account={acct} />
            ))}
          </>
        )}
        {!featuredStatusIds.isEmpty() && (
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
        <RemoteHint accountId={accountId} />
      </div>
    </Column>
  );
};

const AccountFeaturedWrapper = ({
  children,
  accountId,
}: React.PropsWithChildren<{ accountId?: string }>) => {
  return (
    <Column>
      <ColumnBackButton />
      <div className='scrollable scrollable--flex'>
        {accountId && <AccountHeader accountId={accountId} />}
        {children}
      </div>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountFeatured;
