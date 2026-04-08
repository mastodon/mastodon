import { useCallback, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

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
import { me } from 'mastodon/initial_state';

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

export const CollectionAccountsList: React.FC<{
  collection?: ApiCollectionJSON;
  isLoading: boolean;
}> = ({ collection, isLoading }) => {
  const intl = useIntl();
  const confirmRevoke = useConfirmRevoke(collection);
  const listHeadingRef = useRef<HTMLHeadingElement>(null);

  const isOwnCollection = collection?.account_id === me;
  const { items = [], account_id: collectionOwnerId } = collection ?? {};

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
            {items.map(({ account_id }, index) => (
              <Article
                key={account_id}
                aria-posinset={index + 1}
                aria-setsize={items.length}
              >
                <AccountListItem
                  accountId={account_id}
                  withBorder={index !== items.length - 1}
                  stats={['followers', 'last-active']}
                  renderButton={renderAccountItemButton}
                />
              </Article>
            ))}
          </ItemList>
        </SensitiveScreen>
      )}
    </>
  );
};
