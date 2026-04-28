import { useCallback, useMemo, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
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

const getCollectionAccounts = createAppSelector(
  [
    (state) => state.accounts,
    (state, collectionId?: string) =>
      state.collections.collections[collectionId ?? '']?.items,
  ],
  (accounts, collectionAccountItems) =>
    (collectionAccountItems ?? []).map(({ account_id }) =>
      account_id ? accounts.get(account_id) : null,
    ),
);

export const CollectionAccountsList: React.FC<{
  collection?: ApiCollectionJSON;
  isLoading: boolean;
}> = ({ collection, isLoading }) => {
  const intl = useIntl();
  const confirmRevoke = useConfirmRevoke(collection);
  const listHeadingRef = useRef<HTMLHeadingElement>(null);

  const isOwnCollection = collection?.account_id === me;
  const { account_id: collectionOwnerId, id } = collection ?? {};

  const relationships = useAppSelector((state) => state.relationships);
  const collectionAccounts = useAppSelector((state) =>
    getCollectionAccounts(state, id),
  );

  const { visibleAccounts, hiddenAccounts } = useMemo(() => {
    const visibleAccounts: Account[] = [];
    const hiddenAccounts: Account[] = [];

    collectionAccounts.forEach((item) => {
      if (!item) {
        // We currently simply hide unavailable accounts, this includes
        // accounts that are pending inclusion; at least for the collection
        // owner we should display an indication of pending users
        return;
      }

      const relationship = relationships.get(item.id);
      if (relationship?.blocking || relationship?.muting) {
        hiddenAccounts.push(item);
      } else {
        visibleAccounts.push(item);
      }
    });

    return { visibleAccounts, hiddenAccounts };
  }, [collectionAccounts, relationships]);

  const renderAccountItemButton = useCallback(
    ({ relationship, accountId }: RenderButtonOptions) => {
      // When viewing your own collection, only show the Follow button
      // for accounts you're not following anymore.
      const withoutButton =
        !relationship ||
        (collectionOwnerId === me &&
          (relationship.following || relationship.requested));

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
    }: TruncatedListItemInfo<Account>) => (
      <Article
        key={item.id}
        aria-posinset={index + 1}
        aria-setsize={totalListLength}
      >
        <AccountListItem
          accountId={item.id}
          withBorder={!isLastElement}
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
        {collection ? (
          <FormattedMessage
            id='collections.account_count'
            defaultMessage='{count, plural, one {# account} other {# accounts}}'
            values={{ count: collection.item_count }}
          />
        ) : (
          <FormattedMessage
            id='collections.detail.accounts_heading'
            defaultMessage='Accounts'
          />
        )}
      </h3>
      {collection && (
        <SensitiveScreen
          sensitive={!isOwnCollection && collection.sensitive}
          focusTargetRef={listHeadingRef}
        >
          <ItemList
            isLoading={isLoading}
            emptyMessage={intl.formatMessage(messages.empty)}
          >
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
      )}
    </>
  );
};
