import { useCallback, useMemo, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { PendingBadge } from '@/mastodon/components/badge';
import { SelectField } from '@/mastodon/components/form_fields';
import { useSearchParam } from '@/mastodon/hooks/useSearchParam';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';
import type {
  ApiCollectionJSON,
  CollectionAccountItem,
} from 'mastodon/api_types/collections';
import type { RenderButtonOptions } from 'mastodon/components/account_list_item';
import {
  AccountListItem,
  AccountListItemFollowButton,
} from 'mastodon/components/account_list_item';
import { Button } from 'mastodon/components/button';
import {
  Article,
  ItemList,
} from 'mastodon/components/scrollable_list/components';
import type { TruncatedListItemInfo } from 'mastodon/components/truncated_list';
import { TruncatedListItems } from 'mastodon/components/truncated_list';
import { me } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import { createAppSelector, useAppSelector } from 'mastodon/store';

import { useConfirmRevoke } from './revoke_collection_inclusion_modal';
import classes from './styles.module.scss';

const messages = defineMessages({
  empty: {
    id: 'collections.accounts.empty_title',
    defaultMessage: 'This collection is empty',
  },
});

type CollectionItemWithAccount = CollectionAccountItem & {
  account?: Account | null;
};

const getCollectionItems = createAppSelector(
  [
    (state) => state.accounts,
    (state, collectionId?: string) =>
      state.collections.collections[collectionId ?? '']?.items,
  ],
  (accounts, collectionAccountItems) =>
    (collectionAccountItems ?? []).map(
      (item): CollectionItemWithAccount => ({
        ...item,
        account: item.account_id ? accounts.get(item.account_id) : null,
      }),
    ),
);

function sortAccounts(
  accounts: CollectionItemWithAccount[],
  sortBy?: string,
): CollectionItemWithAccount[] {
  if (!sortBy || sortBy === 'date_added') {
    return accounts;
  }

  const sorted = [...accounts];

  switch (sortBy) {
    case 'alphabetical':
      return sorted.sort((a, b) => {
        const nameA = a.account?.display_name ?? '';
        const nameB = b.account?.display_name ?? '';
        return nameA.localeCompare(nameB);
      });

    case 'last_active':
      return sorted.sort((a, b) => {
        const dateA = a.account?.last_status_at ?? '';
        const dateB = b.account?.last_status_at ?? '';
        return new Date(dateB).getTime() - new Date(dateA).getTime();
      });

    case 'most_followers':
      return sorted.sort((a, b) => {
        const followersA = a.account?.followers_count ?? 0;
        const followersB = b.account?.followers_count ?? 0;
        return followersB - followersA;
      });

    default:
      return accounts;
  }
}

export const CollectionAccountsList: React.FC<{
  collection: ApiCollectionJSON;
}> = ({ collection }) => {
  const intl = useIntl();
  const confirmRevoke = useConfirmRevoke(collection);
  const listHeadingRef = useRef<HTMLHeadingElement>(null);

  const isOwnCollection = collection.account_id === me;
  const { account_id: collectionOwnerId, id } = collection;

  const relationships = useAppSelector((state) => state.relationships);
  const collectionAccounts = useAppSelector((state) =>
    getCollectionItems(state, id),
  );

  const [sortBy, setSortBy] = useSearchParam('sort', 'date_added');
  const changeSortBy = useCallback(
    (event: React.ChangeEvent<HTMLSelectElement>) => {
      setSortBy(event.target.value);
    },
    [setSortBy],
  );
  const sortedAccounts = sortAccounts(collectionAccounts, sortBy);

  const { visibleAccounts, hiddenAccounts } = useMemo(() => {
    const visibleAccounts: CollectionItemWithAccount[] = [];
    const hiddenAccounts: CollectionItemWithAccount[] = [];

    sortedAccounts.forEach((item) => {
      const { account, account_id } = item;

      if (!isOwnCollection && !account) {
        // Hide unavailable accounts unless you own this collection
        return;
      }

      const relationship = account_id ? relationships.get(account_id) : null;
      if (relationship?.blocking || relationship?.muting) {
        hiddenAccounts.push(item);
      } else {
        visibleAccounts.push(item);
      }
    });

    return { visibleAccounts, hiddenAccounts };
  }, [sortedAccounts, isOwnCollection, relationships]);

  const renderAccountItemButton = useCallback(
    ({ relationship, accountId }: RenderButtonOptions) => {
      if (!me || !relationship) {
        // Show follow button when logged out (it will trigger the remote interaction modal)
        return <AccountListItemFollowButton accountId={accountId} />;
      }

      // When viewing your own collection, only show the Follow button
      // for accounts you're not following anymore.
      const withoutButton =
        collectionOwnerId === me &&
        (relationship.following || relationship.requested);

      if (withoutButton) return null;

      if (accountId === me) {
        return (
          <Button secondary compact onClick={confirmRevoke}>
            <FormattedMessage
              id='collections.detail.revoke_inclusion'
              defaultMessage='Remove me'
            />
          </Button>
        );
      }

      return <AccountListItemFollowButton accountId={accountId} />;
    },
    [collectionOwnerId, confirmRevoke],
  );

  const renderListItem = useCallback(
    ({
      item,
      index,
      totalListLength,
      isLastElement,
    }: TruncatedListItemInfo<CollectionItemWithAccount>) => (
      <Article
        key={item.id}
        aria-posinset={index + 1}
        aria-setsize={totalListLength}
      >
        <AccountListItem
          accountId={item.account_id}
          withBorder={!isLastElement}
          badge={item.state === 'pending' ? <PendingBadge /> : null}
          renderButton={renderAccountItemButton}
        />
      </Article>
    ),
    [renderAccountItemButton],
  );

  return (
    <>
      <div className={classes.subheadingWithSelect}>
        <h3
          className={classes.columnSubheading}
          tabIndex={-1}
          ref={listHeadingRef}
        >
          <FormattedMessage
            id='collections.account_count'
            defaultMessage='{count, plural, one {# account} other {# accounts}}'
            values={{ count: collection.item_count }}
          />
        </h3>
        <SelectField
          label={
            <FormattedMessage
              id='collections.sort_by'
              defaultMessage='Sort by:'
            />
          }
          value={sortBy}
          onChange={changeSortBy}
          inputPlacement='inline-end'
          className={classes.select}
          wrapperClassName={classes.selectWrapper}
        >
          <option value='alphabetical'>
            <FormattedMessage
              id='collections.sort_alphabetical'
              defaultMessage='Alphabetical'
            />
          </option>
          <option value='last_active'>
            <FormattedMessage
              id='collections.sort_last_active'
              defaultMessage='Last active'
            />
          </option>
          <option value='most_followers'>
            <FormattedMessage
              id='collections.sort_most_followers'
              defaultMessage='Most followers'
            />
          </option>
          <option value='date_added'>
            <FormattedMessage
              id='collections.sort_date_added'
              defaultMessage='Date added'
            />
          </option>
        </SelectField>
      </div>
      <ItemList emptyMessage={intl.formatMessage(messages.empty)}>
        <TruncatedListItems
          visibleItems={visibleAccounts}
          truncatedItems={hiddenAccounts}
          toggleButton={{
            icon: VisibilityOffIcon,
            title: (
              <FormattedMessage
                id='collections.hidden_accounts_link'
                defaultMessage='{count, plural, one {# hidden account} other {# hidden accounts}}'
                values={{ count: hiddenAccounts.length }}
              />
            ),
            subtitle: (
              <FormattedMessage
                id='collections.hidden_accounts_description'
                defaultMessage='You’ve blocked or muted {count, plural, one {this user} other {these users}}'
                values={{ count: hiddenAccounts.length }}
              />
            ),
          }}
          renderListItem={renderListItem}
        />
      </ItemList>
    </>
  );
};
