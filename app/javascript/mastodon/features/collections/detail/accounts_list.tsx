import { useCallback, useMemo, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { PendingBadge } from '@/mastodon/components/badge';
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
import { Callout } from 'mastodon/components/callout';
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

const SensitiveScreen: React.FC<{
  sensitive: boolean | undefined;
  focusTargetRef: React.RefObject<HTMLHeadingElement>;
  children: React.ReactNode;
}> = ({ sensitive, focusTargetRef, children }) => {
  const [isVisible, setIsVisible] = useState(!sensitive);

  const showAnyway = useCallback(() => {
    setIsVisible(true);
    setTimeout(() => {
      focusTargetRef.current?.focus();
    }, 0);
  }, [focusTargetRef]);

  if (isVisible) {
    return children;
  }

  return (
    <Callout
      variant='warning'
      title={
        <FormattedMessage
          id='collections.detail.sensitive_content'
          defaultMessage='Sensitive content'
        />
      }
      primaryLabel={
        <FormattedMessage
          id='content_warning.show_short'
          defaultMessage='Show'
        />
      }
      onPrimary={showAnyway}
      className={classes.sensitiveScreen}
    >
      <FormattedMessage
        id='collections.detail.sensitive_note'
        defaultMessage='The description and accounts may not be suitable for all viewers.'
      />
    </Callout>
  );
};

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

  const { visibleAccounts, hiddenAccounts } = useMemo(() => {
    const visibleAccounts: CollectionItemWithAccount[] = [];
    const hiddenAccounts: CollectionItemWithAccount[] = [];

    collectionAccounts.forEach((item) => {
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
  }, [collectionAccounts, isOwnCollection, relationships]);

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
      <SensitiveScreen
        sensitive={!isOwnCollection && collection.sensitive}
        focusTargetRef={listHeadingRef}
      >
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
      </SensitiveScreen>
    </>
  );
};
