import { useCallback, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Account } from 'mastodon/components/account';
import { Button } from 'mastodon/components/button';
import { Callout } from 'mastodon/components/callout';
import { FollowButton } from 'mastodon/components/follow_button';
import {
  NumberFields,
  NumberFieldsItem,
} from 'mastodon/components/number_fields';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import {
  Article,
  ItemList,
} from 'mastodon/components/scrollable_list/components';
import { ShortNumber } from 'mastodon/components/short_number';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useRelationship } from 'mastodon/hooks/useRelationship';
import { me } from 'mastodon/initial_state';

import { useConfirmRevoke } from './revoke_collection_inclusion_modal';
import classes from './styles.module.scss';

const messages = defineMessages({
  empty: {
    id: 'collections.accounts.empty_title',
    defaultMessage: 'This collection is empty',
  },
});

const AccountItem: React.FC<{
  accountId: string | undefined;
  collectionOwnerId: string;
  onRevoke: () => void;
  withBio?: boolean;
  withBorder?: boolean;
}> = ({
  accountId,
  collectionOwnerId,
  onRevoke,
  withBio = true,
  withBorder = true,
}) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const relationship = useRelationship(accountId);

  if (!accountId || !account) {
    return null;
  }

  // When viewing your own collection, only show the Follow button
  // for accounts you're not following (anymore).
  // Otherwise, always show the follow button in its various states.
  const isOwnAccount = accountId === me;
  const withoutButton =
    isOwnAccount ||
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
        extraAccountInfo={
          <NumberFields>
            <NumberFieldsItem
              label={
                <FormattedMessage
                  id='account.followers'
                  defaultMessage='Followers'
                />
              }
              hint={intl.formatNumber(account.followers_count)}
            >
              <ShortNumber value={account.followers_count} />
            </NumberFieldsItem>

            <NumberFieldsItem
              label={
                <FormattedMessage id='account.posts' defaultMessage='Posts' />
              }
              hint={intl.formatNumber(account.statuses_count)}
            >
              <ShortNumber value={account.statuses_count} />
            </NumberFieldsItem>

            <NumberFieldsItem
              label={
                <FormattedMessage
                  id='account.last_active'
                  defaultMessage='Last active'
                />
              }
            >
              <RelativeTimestamp
                long
                timestamp={account.last_status_at}
                noFuture
              />
            </NumberFieldsItem>
          </NumberFields>
        }
      />
      {!withoutButton && <FollowButton compact accountId={accountId} />}
      {isOwnAccount && (
        <Button secondary compact onClick={onRevoke}>
          <FormattedMessage
            id='collections.detail.revoke_inclusion'
            defaultMessage='Remove me'
          />
        </Button>
      )}
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

export const CollectionAccountsList: React.FC<{
  collection?: ApiCollectionJSON;
  isLoading: boolean;
}> = ({ collection, isLoading }) => {
  const intl = useIntl();
  const confirmRevoke = useConfirmRevoke(collection);
  const listHeadingRef = useRef<HTMLHeadingElement>(null);

  const isOwnCollection = collection?.account_id === me;
  const { items = [] } = collection ?? {};

  return (
    <ItemList
      isLoading={isLoading}
      emptyMessage={intl.formatMessage(messages.empty)}
      className={classes.itemList}
    >
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
          {items.map(({ account_id }, index) => (
            <Article
              key={account_id}
              aria-posinset={index + 1}
              aria-setsize={items.length}
            >
              <AccountItem
                withBorder={index !== items.length - 1}
                accountId={account_id}
                collectionOwnerId={collection.account_id}
                onRevoke={confirmRevoke}
              />
            </Article>
          ))}
        </SensitiveScreen>
      )}
    </ItemList>
  );
};
