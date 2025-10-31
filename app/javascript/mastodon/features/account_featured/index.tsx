import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';

import { List as ImmutableList } from 'immutable';

import { fetchEndorsedAccounts } from 'mastodon/actions/accounts';
import { fetchFeaturedTags } from 'mastodon/actions/featured_tags';
import { Account } from 'mastodon/components/account';
import { ColumnBackButton } from 'mastodon/components/column_back_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { RemoteHint } from 'mastodon/components/remote_hint';
import { AccountHeader } from 'mastodon/features/account_timeline/components/account_header';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import Column from 'mastodon/features/ui/components/column';
import { useAccountId } from 'mastodon/hooks/useAccountId';
import { useAccountVisibility } from 'mastodon/hooks/useAccountVisibility';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { EmptyMessage } from './components/empty_message';
import { FeaturedTag } from './components/featured_tag';
import type { TagMap } from './components/featured_tag';

interface Params {
  acct?: string;
  id?: string;
}

const AccountFeatured: React.FC<{ multiColumn: boolean }> = ({
  multiColumn,
}) => {
  const accountId = useAccountId();
  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);
  const forceEmptyState = suspended || blockedBy || hidden;
  const { acct = '' } = useParams<Params>();

  const dispatch = useAppDispatch();

  useEffect(() => {
    if (accountId) {
      void dispatch(fetchFeaturedTags({ accountId }));
      void dispatch(fetchEndorsedAccounts({ accountId }));
    }
  }, [accountId, dispatch]);

  const isLoading = useAppSelector(
    (state) =>
      !accountId ||
      !!state.user_lists.getIn(['featured_tags', accountId, 'isLoading']),
  );
  const featuredTags = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['featured_tags', accountId, 'items'],
        ImmutableList(),
      ) as ImmutableList<TagMap>,
  );
  const featuredAccountIds = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['featured_accounts', accountId, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );

  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (isLoading) {
    return (
      <AccountFeaturedWrapper accountId={accountId}>
        <div className='scrollable__append'>
          <LoadingIndicator />
        </div>
      </AccountFeaturedWrapper>
    );
  }

  if (featuredTags.isEmpty() && featuredAccountIds.isEmpty()) {
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
        {!featuredAccountIds.isEmpty() && (
          <>
            <h4 className='column-subheading'>
              <FormattedMessage
                id='account.featured.accounts'
                defaultMessage='Profiles'
              />
            </h4>
            {featuredAccountIds.map((featuredAccountId) => (
              <Account key={featuredAccountId} id={featuredAccountId} />
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
