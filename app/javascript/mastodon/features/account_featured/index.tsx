import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHistory } from 'react-router';

import { List as ImmutableList } from 'immutable';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { fetchEndorsedAccounts } from 'mastodon/actions/accounts';
import { Account } from 'mastodon/components/account';
import { ColumnBackButton } from 'mastodon/components/column_back_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { RemoteHint } from 'mastodon/components/remote_hint';
import {
  Article,
  ItemList,
  Scrollable,
} from 'mastodon/components/scrollable_list/components';
import { AccountHeader } from 'mastodon/features/account_timeline/components/account_header';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import Column from 'mastodon/features/ui/components/column';
import { useAccountId } from 'mastodon/hooks/useAccountId';
import { useAccountVisibility } from 'mastodon/hooks/useAccountVisibility';
import {
  fetchAccountCollections,
  selectAccountCollections,
} from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { CollectionListItem } from '../collections/detail/collection_list_item';
import { areCollectionsEnabled } from '../collections/utils';

import { EmptyMessage } from './components/empty_message';

const AccountFeatured: React.FC<{ multiColumn: boolean }> = ({
  multiColumn,
}) => {
  const accountId = useAccountId();
  const account = useAccount(accountId);
  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);
  const forceEmptyState = suspended || blockedBy || hidden;

  const dispatch = useAppDispatch();

  const history = useHistory();
  useEffect(() => {
    if (account && !account.show_featured) {
      history.push(`/@${account.acct}`);
    }
  }, [account, history]);

  useEffect(() => {
    if (accountId) {
      void dispatch(fetchEndorsedAccounts({ accountId }));

      if (areCollectionsEnabled()) {
        void dispatch(fetchAccountCollections({ accountId }));
      }
    }
  }, [accountId, dispatch]);

  const isLoading = !accountId;
  const featuredAccountIds = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['featured_accounts', accountId, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );
  const { collections, status } = useAppSelector((state) =>
    selectAccountCollections(state, accountId ?? null),
  );
  const listedCollections = collections.filter(
    // Hide unlisted and empty collections to avoid confusion
    // (Unlisted collections will only be part of the payload
    // when viewing your own profile.)
    (item) => item.discoverable && !!item.item_count,
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

  if (featuredAccountIds.isEmpty() && listedCollections.length === 0) {
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

      <Scrollable>
        {accountId && (
          <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
        )}
        {listedCollections.length > 0 && status === 'idle' && (
          <>
            <h4 className='column-subheading'>
              <FormattedMessage
                id='account.featured.collections'
                defaultMessage='Collections'
              />
            </h4>
            <ItemList>
              {listedCollections.map((item, index) => (
                <CollectionListItem
                  key={item.id}
                  collection={item}
                  withoutBorder={index === listedCollections.length - 1}
                  withAuthorHandle={false}
                  positionInList={index + 1}
                  listSize={listedCollections.length}
                />
              ))}
            </ItemList>
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
            <ItemList>
              {featuredAccountIds.map((featuredAccountId, index) => (
                <Article
                  focusable
                  key={featuredAccountId}
                  aria-posinset={index + 1}
                  aria-setsize={featuredAccountIds.size}
                >
                  <Account id={featuredAccountId} />
                </Article>
              ))}
            </ItemList>
          </>
        )}
        <RemoteHint accountId={accountId} />
      </Scrollable>
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
