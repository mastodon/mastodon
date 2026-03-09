import { Fragment, useCallback, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { openModal } from 'flavours/glitch/actions/modal';
import type {
  ApiCollectionJSON,
  CollectionAccountItem,
} from 'flavours/glitch/api_types/collections';
import { Account } from 'flavours/glitch/components/account';
import { Button } from 'flavours/glitch/components/button';
import { DisplayName } from 'flavours/glitch/components/display_name';
import {
  Article,
  ItemList,
} from 'flavours/glitch/components/scrollable_list/components';
import { useAccount } from 'flavours/glitch/hooks/useAccount';
import { useDismissible } from 'flavours/glitch/hooks/useDismissible';
import { useRelationship } from 'flavours/glitch/hooks/useRelationship';
import { me } from 'flavours/glitch/initial_state';
import { useAppDispatch } from 'flavours/glitch/store';

import classes from './styles.module.scss';

const messages = defineMessages({
  empty: {
    id: 'collections.accounts.empty_title',
    defaultMessage: 'This collection is empty',
  },
  accounts: {
    id: 'collections.detail.accounts_heading',
    defaultMessage: 'Accounts',
  },
});

const SimpleAuthorName: React.FC<{ id: string }> = ({ id }) => {
  const account = useAccount(id);
  return <DisplayName account={account} variant='simple' />;
};

const AccountItem: React.FC<{
  accountId: string | undefined;
  collectionOwnerId: string;
  withBorder?: boolean;
}> = ({ accountId, withBorder = true, collectionOwnerId }) => {
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
    <Account
      minimal={withoutButton}
      withMenu={false}
      withBorder={withBorder}
      id={accountId}
    />
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
          tagName={Fragment}
        />
      </Button>
      <Button secondary onClick={confirmRevoke}>
        <FormattedMessage
          id='collections.detail.revoke_inclusion'
          defaultMessage='Remove me'
          tagName={Fragment}
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
    <div className={classes.sensitiveWarning}>
      <FormattedMessage
        id='collections.detail.sensitive_note'
        defaultMessage='This collection contains accounts and content that may be sensitive to some users.'
        tagName='p'
      />
      <Button onClick={showAnyway}>
        <FormattedMessage
          id='content_warning.show'
          defaultMessage='Show anyway'
          tagName={Fragment}
        />
      </Button>
    </div>
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
    >
      {collection && currentUserInCollection ? (
        <>
          <h3 className={classes.columnSubheading}>
            <FormattedMessage
              id='collections.detail.author_added_you'
              defaultMessage='{author} added you to this collection'
              values={{
                author: <SimpleAuthorName id={collection.account_id} />,
              }}
              tagName={Fragment}
            />
          </h3>
          <Article
            key={currentUserInCollection.account_id}
            aria-posinset={1}
            aria-setsize={items.length}
          >
            <AccountItem
              withBorder={false}
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
              id='collections.detail.other_accounts_in_collection'
              defaultMessage='Others in this collection:'
              tagName={Fragment}
            />
          </h3>
        </>
      ) : (
        <h3
          className='column-subheading sr-only'
          tabIndex={-1}
          ref={listHeadingRef}
        >
          {intl.formatMessage(messages.accounts)}
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
