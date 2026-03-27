import { useCallback, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Callout } from '@/mastodon/components/callout';
import { FollowButton } from '@/mastodon/components/follow_button';
import { openModal } from 'mastodon/actions/modal';
import type {
  ApiCollectionJSON,
  CollectionAccountItem,
} from 'mastodon/api_types/collections';
import { Account } from 'mastodon/components/account';
import { Button } from 'mastodon/components/button';
import { DisplayName } from 'mastodon/components/display_name';
import {
  Article,
  ItemList,
} from 'mastodon/components/scrollable_list/components';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useDismissible } from 'mastodon/hooks/useDismissible';
import { useRelationship } from 'mastodon/hooks/useRelationship';
import { me } from 'mastodon/initial_state';
import { useAppDispatch } from 'mastodon/store';

import classes from './styles.module.scss';

const messages = defineMessages({
  empty: {
    id: 'collections.accounts.empty_title',
    defaultMessage: 'This collection is empty',
  },
});

const SimpleAuthorName: React.FC<{ id: string }> = ({ id }) => {
  const account = useAccount(id);
  return <DisplayName account={account} variant='simple' />;
};

const AccountItem: React.FC<{
  accountId: string | undefined;
  collectionOwnerId: string;
  withBio?: boolean;
  withBorder?: boolean;
}> = ({ accountId, withBio = true, withBorder = true, collectionOwnerId }) => {
  const relationship = useRelationship(accountId);

  if (!accountId) {
    return null;
  }

  // When viewing your own collection, only show the Follow button
  // for accounts you're not following (anymore).
  // Otherwise, always show the follow button in its various states.
  const withoutButton =
    accountId === me ||
    !relationship ||
    (collectionOwnerId === me &&
      (relationship.following || relationship.requested));

  return (
    <div className={classes.accountItemWrapper} data-with-border={withBorder}>
      <Account
        minimal
        id={accountId}
        withBio={withBio}
        withBorder={false}
        withMenu={false}
        className={classes.accountItem}
      />
      {!withoutButton && <FollowButton accountId={accountId} />}
    </div>
  );
};

const RevokeControls: React.FC<{
  collectionId: string;
  collectionItem: CollectionAccountItem;
}> = ({ collectionId, collectionItem }) => {
  const dispatch = useAppDispatch();

  const confirmRevoke = useCallback(() => {
    void dispatch(
      openModal({
        modalType: 'REVOKE_COLLECTION_INCLUSION',
        modalProps: {
          collectionId,
          collectionItemId: collectionItem.id,
        },
      }),
    );
  }, [collectionId, collectionItem.id, dispatch]);

  const { wasDismissed, dismiss } = useDismissible(
    `collection-revoke-hint-${collectionItem.id}`,
  );

  if (wasDismissed) {
    return null;
  }

  return (
    <div className={classes.revokeControlWrapper}>
      <Button secondary onClick={dismiss}>
        <FormattedMessage
          id='collections.detail.accept_inclusion'
          defaultMessage='Okay'
        />
      </Button>
      <Button secondary onClick={confirmRevoke}>
        <FormattedMessage
          id='collections.detail.revoke_inclusion'
          defaultMessage='Remove me'
        />
      </Button>
    </div>
  );
};

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
    >
      <FormattedMessage
        id='collections.detail.sensitive_note'
        defaultMessage='The description and accounts may not be suitable for all viewers.'
      />
    </Callout>
  );
};

/**
 * Returns the collection's account items. If the current user's account
 * is part of the collection, it will be returned separately.
 */
function getCollectionItems(collection: ApiCollectionJSON | undefined) {
  if (!collection)
    return {
      currentUserInCollection: null,
      items: [],
    };

  const { account_id, items } = collection;

  const isOwnCollection = account_id === me;
  const currentUserIndex = items.findIndex(
    (account) => account.account_id === me,
  );

  if (isOwnCollection || currentUserIndex === -1) {
    return {
      currentUserInCollection: null,
      items,
    };
  } else {
    return {
      currentUserInCollection: items.at(currentUserIndex) ?? null,
      items: items.toSpliced(currentUserIndex, 1),
    };
  }
}

export const CollectionAccountsList: React.FC<{
  collection?: ApiCollectionJSON;
  isLoading: boolean;
}> = ({ collection, isLoading }) => {
  const intl = useIntl();
  const listHeadingRef = useRef<HTMLHeadingElement>(null);

  const isOwnCollection = collection?.account_id === me;
  const { items, currentUserInCollection } = getCollectionItems(collection);

  return (
    <ItemList
      isLoading={isLoading}
      emptyMessage={intl.formatMessage(messages.empty)}
      className={classes.itemList}
    >
      {collection && currentUserInCollection ? (
        <>
          <h3 className={classes.columnSubheading}>
            <FormattedMessage
              id='collections.detail.you_were_added_to_this_collection'
              defaultMessage='You were added to this collection'
              values={{
                author: <SimpleAuthorName id={collection.account_id} />,
              }}
            />
          </h3>
          <Article
            key={currentUserInCollection.account_id}
            aria-posinset={1}
            aria-setsize={items.length}
            className={classes.youWereAddedWrapper}
          >
            <AccountItem
              withBorder={false}
              withBio={false}
              accountId={currentUserInCollection.account_id}
              collectionOwnerId={collection.account_id}
            />
            <RevokeControls
              collectionId={collection.id}
              collectionItem={currentUserInCollection}
            />
          </Article>
          <h3
            className={classes.columnSubheading}
            tabIndex={-1}
            ref={listHeadingRef}
          >
            <FormattedMessage
              id='collections.detail.other_accounts_count'
              defaultMessage='{count, plural, one {# other account} other {# other accounts}}'
              values={{ count: collection.item_count - 1 }}
            />
          </h3>
        </>
      ) : (
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
      )}
      {collection && (
        <SensitiveScreen
          sensitive={!isOwnCollection && collection.sensitive}
          focusTargetRef={listHeadingRef}
        >
          {items.map(({ account_id }, index, items) => (
            <Article
              key={account_id}
              aria-posinset={index + (currentUserInCollection ? 2 : 1)}
              aria-setsize={items.length}
            >
              <AccountItem
                accountId={account_id}
                collectionOwnerId={collection.account_id}
              />
            </Article>
          ))}
        </SensitiveScreen>
      )}
    </ItemList>
  );
};
