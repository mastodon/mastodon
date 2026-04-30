import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import { EmptyState } from 'mastodon/components/empty_state';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ItemList } from 'mastodon/components/scrollable_list/components';
import { useAccountId, useCurrentAccountId } from 'mastodon/hooks/useAccountId';
import {
  fetchCollectionsCreatedByAccount,
  selectAccountCollections,
} from 'mastodon/reducers/slices/collections';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { CollectionListItem } from '../components/collection_list_item';
import {
  messages as editorMessages,
  MaxCollectionsCallout,
  userCollectionLimit,
} from '../editor';
import classes from '../styles.module.scss';
import { areCollectionsEnabled } from '../utils';

const CreateButton: React.FC = () => (
  <Link to='/collections/new' className='button button--compact'>
    <Icon id='plus' icon={AddIcon} />
    <FormattedMessage {...editorMessages.newCollection} />
  </Link>
);

export const CollectionListError: React.FC = () => (
  <EmptyState
    image={null}
    className={classes.error}
    message={
      <FormattedMessage
        id='collections.error_loading_collections'
        defaultMessage='There was an error when trying to load these collections.'
      />
    }
  />
);

export function useCollectionsCreatedBy(accountId: string | null | undefined) {
  const dispatch = useAppDispatch();

  useEffect(() => {
    if (accountId && areCollectionsEnabled()) {
      void dispatch(fetchCollectionsCreatedByAccount({ accountId }));
    }
  }, [dispatch, accountId]);

  return useAppSelector((state) =>
    selectAccountCollections(state, accountId, 'createdBy'),
  );
}

export const CollectionsCreatedByYou: React.FC = () => {
  const me = useCurrentAccountId();
  const accountId = useAccountId();

  const { collections, status } = useCollectionsCreatedBy(accountId);

  const canCreateMoreCollections = collections.length < userCollectionLimit;
  const isOwnCollectionPage = accountId === me;
  const showCreateButton =
    isOwnCollectionPage && status === 'idle' && canCreateMoreCollections;

  if (status === 'error' || !accountId) {
    return <CollectionListError />;
  }

  if (status === 'loading') {
    return <LoadingIndicator />;
  }

  if (collections.length === 0) {
    return (
      <EmptyState
        title={
          <FormattedMessage
            id='empty_column.account_featured_self.showcase_accounts'
            defaultMessage='Showcase your favorite accounts'
          />
        }
        message={
          <FormattedMessage
            id='empty_column.account_featured_self.showcase_accounts_desc'
            defaultMessage='Collections are curated lists of accounts to help others discover more of the Fediverse.'
          />
        }
      >
        <CreateButton />
      </EmptyState>
    );
  }

  return (
    <>
      <div className={classes.listHeader}>
        <h2 className={classes.subHeading}>
          <FormattedMessage
            id='collections.list.collections_with_count'
            defaultMessage='{count, plural, one {# Collection} other {# Collections}}'
            values={{
              count: collections.length,
            }}
          />
        </h2>
        {showCreateButton && <CreateButton />}
      </div>
      <ItemList>
        {!canCreateMoreCollections && (
          <MaxCollectionsCallout className={classes.maxCollectionsError} />
        )}
        {collections.map((item, index) => (
          <CollectionListItem
            withTimestamp
            withAuthorHandle={false}
            key={item.id}
            collection={item}
            positionInList={index + 1}
            listSize={collections.length}
          />
        ))}
      </ItemList>
    </>
  );
};
