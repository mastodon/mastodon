import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { useAccount } from '@/mastodon/hooks/useAccount';
import { EmptyState } from 'mastodon/components/empty_state';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ItemList } from 'mastodon/components/scrollable_list/components';
import { useAccountId } from 'mastodon/hooks/useAccountId';
import {
  fetchCollectionsFeaturingAccount,
  selectAccountCollections,
} from 'mastodon/reducers/slices/collections';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { CollectionListItem } from '../components/collection_list_item';
import classes from '../styles.module.scss';
import { areCollectionsEnabled } from '../utils';

import { CollectionListError } from './created_by_you';

function useCollectionsFeaturing(accountId: string | null | undefined) {
  const dispatch = useAppDispatch();

  useEffect(() => {
    if (accountId && areCollectionsEnabled()) {
      void dispatch(fetchCollectionsFeaturingAccount({ accountId }));
    }
  }, [dispatch, accountId]);

  return useAppSelector((state) =>
    selectAccountCollections(state, accountId, 'featuring'),
  );
}

export const CollectionsFeaturingYou: React.FC = () => {
  const accountId = useAccountId();
  const account = useAccount(accountId);

  const { collections, status } = useCollectionsFeaturing(accountId);

  if (status === 'error' || !accountId) {
    return <CollectionListError />;
  }

  if (status === 'loading') {
    return <LoadingIndicator />;
  }

  if (collections.length === 0) {
    if (account?.discoverable) {
      return (
        <EmptyState
          message={
            <FormattedMessage
              id='empty_column.collections.featured_in'
              defaultMessage='You have not been added to any collections yet.'
            />
          }
        />
      );
    } else {
      return (
        <EmptyState
          message={
            <>
              <FormattedMessage
                id='empty_column.collections.featured_in'
                defaultMessage='You have not been added to any collections yet.'
              />
              <br />
              <FormattedMessage
                id='empty_column.collections.featured_in_undiscoverable'
                defaultMessage='In order for people to add you to collections, you need to allow featuring in discovery experiences from <link>Preferences > Privacy and reach</link>'
                values={{
                  link: (chunks) => (
                    <a href='/settings/privacy#account_discoverable'>
                      {chunks}
                    </a>
                  ),
                }}
              />
            </>
          }
        />
      );
    }
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
      </div>
      <ItemList>
        {collections.map((item, index) => (
          <CollectionListItem
            withAuthorHandle
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
