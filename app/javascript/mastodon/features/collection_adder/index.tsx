import { useCallback, useId, useState } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import type { ApiCollectionJSON } from '@/mastodon/api_types/collections';
import { EmptyState } from '@/mastodon/components/empty_state';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { NavigationFocusTarget } from '@/mastodon/components/navigation_focus_target';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import type { Account } from '@/mastodon/models/account';
import {
  addCollectionItem,
  removeCollectionItem,
} from '@/mastodon/reducers/slices/collections';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { IconButton } from 'mastodon/components/icon_button';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { MAX_COLLECTION_ACCOUNT_COUNT } from '../collections/editor/accounts';
import {
  NewCollectionButton,
  useCollectionsCreatedBy,
} from '../collections/overview/created_by_account';

import { CollectionToggle } from './collection_toggle';

const messages = defineMessages({
  close: {
    id: 'lightbox.close',
    defaultMessage: 'Close',
  },
});

const ListItem: React.FC<{
  collection: ApiCollectionJSON;
  account: Account;
}> = ({ collection, account }) => {
  const dispatch = useAppDispatch();
  const [isUpdating, setIsUpdating] = useState(false);

  const accountItemInCollection = collection.items.find(
    (item) => item.account_id === account.id,
  );
  const isAccountInCollection = !!accountItemInCollection;

  const addOrRemove = useCallback(
    async (shouldAdd: boolean) => {
      setIsUpdating(true);

      if (shouldAdd) {
        await dispatch(
          addCollectionItem({
            collectionId: collection.id,
            accountId: account.id,
          }),
        );
      } else if (accountItemInCollection) {
        await dispatch(
          removeCollectionItem({
            collectionId: collection.id,
            itemId: accountItemInCollection.id,
          }),
        );
      }

      setIsUpdating(false);
    },
    [account.id, collection.id, accountItemInCollection, dispatch],
  );

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      void addOrRemove(e.target.checked);
    },
    [addOrRemove],
  );

  const hasMaxItemCount =
    !isAccountInCollection &&
    collection.item_count >= MAX_COLLECTION_ACCOUNT_COUNT;

  return (
    <CollectionToggle
      key={collection.id}
      collection={collection}
      disabled={isUpdating || hasMaxItemCount}
      subtitle={
        hasMaxItemCount ? (
          <FormattedMessage
            id='collections.search_accounts_max_reached'
            defaultMessage='You have added the maximum number of accounts'
          />
        ) : null
      }
      checked={isAccountInCollection}
      onChange={handleChange}
    />
  );
};

export const CollectionAdder: React.FC<{
  accountId: string;
  onClose: () => void;
}> = ({ accountId, onClose }) => {
  const intl = useIntl();
  const titleId = useId();
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const currentAccountId = useCurrentAccountId();
  const { collections, status } = useCollectionsCreatedBy(currentAccountId);

  return (
    <div className='modal-root__modal dialog-modal'>
      <div className='dialog-modal__header'>
        <IconButton
          className='dialog-modal__header__close'
          title={intl.formatMessage(messages.close)}
          icon='times'
          iconComponent={CloseIcon}
          onClick={onClose}
        />

        <NavigationFocusTarget
          as='h1'
          id={titleId}
          className='dialog-modal__header__title'
        >
          <FormattedMessage
            id='collections.add_to_collection'
            defaultMessage='Add {name} to collections'
            values={{ name: <strong>@{account?.acct}</strong> }}
          />
        </NavigationFocusTarget>
      </div>

      <div className='dialog-modal__content'>
        <div
          className='lists-scrollable'
          role='group'
          aria-labelledby={titleId}
        >
          {status === 'loading' || !account ? (
            <LoadingIndicator />
          ) : collections.length === 0 ? (
            <EmptyState
              title={
                <FormattedMessage
                  id='empty_column.collections_self'
                  defaultMessage='You have not created any collections yet.'
                />
              }
              message={
                <FormattedMessage
                  id='empty_column.account_featured_self.showcase_accounts_desc'
                  defaultMessage='Collections are curated lists of accounts to help others discover more of the Fediverse.'
                />
              }
            >
              <NewCollectionButton onClick={onClose} />
            </EmptyState>
          ) : (
            collections.map((item) => (
              <ListItem key={item.id} collection={item} account={account} />
            ))
          )}
        </div>
      </div>
    </div>
  );
};
