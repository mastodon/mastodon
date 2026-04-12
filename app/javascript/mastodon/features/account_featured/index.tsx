import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHistory } from 'react-router';

import { List as ImmutableList } from 'immutable';

import { AccountListItem } from '@/mastodon/components/account_list_item';
import { useAccount } from '@/mastodon/hooks/useAccount';
import AddIcon from '@/material-icons/400-24px/add.svg?react';
import { fetchEndorsedAccounts } from 'mastodon/actions/accounts';
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

import { CollectionListItem } from '../collections/components/collection_list_item';
import { areCollectionsEnabled } from '../collections/utils';

import { EmptyMessage } from './components/empty_message';
import { Subheading, SubheadingLink } from './components/subheading';

const collectionsEnabled = areCollectionsEnabled();

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

      if (collectionsEnabled) {
        void dispatch(fetchAccountCollections({ accountId }));
      }
    }
  }, [accountId, dispatch]);

  const featuredAccountIds = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['featured_accounts', accountId, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );
  const { collections, status: collectionsLoadStatus } = useAppSelector(
    (state) => selectAccountCollections(state, accountId ?? null),
  );
  const listedCollections = collections.filter(
    // Hide unlisted and empty collections to avoid confusion
    // (Unlisted collections will only be part of the payload
    // when viewing your own profile.)
    (item) => item.discoverable && !!item.item_count,
  );

  const hasCollections =
    collectionsEnabled &&
    collectionsLoadStatus === 'idle' &&
    listedCollections.length > 0;

  const hasFeaturedAccounts = !featuredAccountIds.isEmpty();

  const isLoading = !accountId || collectionsLoadStatus !== 'idle';

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

  if (!hasFeaturedAccounts && !hasCollections) {
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
        {!featuredAccountIds.isEmpty() && (
          <>
            <Subheading as='h2'>
              <FormattedMessage
                id='account.featured.accounts'
                defaultMessage='Profiles'
              />
            </Subheading>
            <ItemList>
              {featuredAccountIds.map((featuredAccountId, index) => (
                <Article
                  focusable
                  key={featuredAccountId}
                  aria-posinset={index + 1}
                  aria-setsize={featuredAccountIds.size}
                >
                  <AccountListItem accountId={featuredAccountId} />
                </Article>
              ))}
            </ItemList>
          </>
        )}
        {collectionsEnabled && (
          <>
            <Subheading as='header'>
              <h2>
                <FormattedMessage
                  id='account.featured.collections'
                  defaultMessage='Collections'
                />
              </h2>
              <SubheadingLink to='/collections/new' icon={AddIcon}>
                <FormattedMessage
                  id='account.featured.new_collection'
                  defaultMessage='New collection'
                />
              </SubheadingLink>
            </Subheading>
            {hasCollections ? (
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
            ) : (
              <EmptyMessage
                withoutAddCollectionButton
                blockedBy={blockedBy}
                hidden={hidden}
                suspended={suspended}
                accountId={accountId}
              />
            )}
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
