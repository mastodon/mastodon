import { useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import { TabLink, TabList } from '@/mastodon/components/tab_list';
import AddIcon from '@/material-icons/400-24px/add.svg?react';
import SquigglyArrow from '@/svg-icons/squiggly_arrow.svg?react';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { DisplayNameSimple } from 'mastodon/components/display_name/simple';
import { Icon } from 'mastodon/components/icon';
import {
  ItemList,
  Scrollable,
} from 'mastodon/components/scrollable_list/components';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useAccountId, useCurrentAccountId } from 'mastodon/hooks/useAccountId';
import {
  fetchAccountCollections,
  selectAccountCollections,
} from 'mastodon/reducers/slices/collections';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { CollectionListItem } from './components/collection_list_item';
import {
  messages as editorMessages,
  MaxCollectionsCallout,
  userCollectionLimit,
} from './editor';
import classes from './styles.module.scss';
import { areCollectionsEnabled } from './utils';

const messages = defineMessages({
  headingMe: {
    id: 'column.your_collections',
    defaultMessage: 'Your Collections',
  },
  headingOther: {
    id: 'column.other_collections',
    defaultMessage: "{name}'s Collections",
  },
  createdByYou: {
    id: 'collections.list.created_by_you',
    defaultMessage: 'Created by you',
  },
  createdByAuthor: {
    id: 'collections.list.created_by_author',
    defaultMessage: 'Created by {name}',
  },
  featuringYou: {
    id: 'collections.list.featuring_you',
    defaultMessage: 'Featuring you',
  },
});

export function useAccountCollections(accountId: string | null | undefined) {
  const dispatch = useAppDispatch();

  useEffect(() => {
    if (accountId && areCollectionsEnabled()) {
      void dispatch(fetchAccountCollections({ accountId }));
    }
  }, [dispatch, accountId]);

  return useAppSelector((state) => selectAccountCollections(state, accountId));
}

export const Collections: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const me = useCurrentAccountId();
  const accountId = useAccountId();
  const account = useAccount(accountId);

  const { collections, status } = useAccountCollections(accountId);

  const emptyMessage =
    status === 'error' || !accountId ? (
      <FormattedMessage
        id='collections.error_loading_collections'
        defaultMessage='There was an error when trying to load your collections.'
        tagName='span'
      />
    ) : (
      <>
        <span>
          <FormattedMessage
            id='collections.no_collections_yet'
            defaultMessage='No collections yet.'
          />
          <br />
          <FormattedMessage
            id='collections.create_a_collection_hint'
            defaultMessage='Create a collection to recommend or share your favourite accounts with others.'
          />
        </span>

        <SquigglyArrow className='empty-column-indicator__arrow' />
      </>
    );

  const canCreateMoreCollections = collections.length < userCollectionLimit;
  const isOwnCollection = accountId === me;
  const showCreateButton =
    isOwnCollection && status === 'idle' && canCreateMoreCollections;

  const titleMessage = isOwnCollection
    ? messages.headingMe
    : messages.headingOther;

  const pageTitle = intl.formatMessage(titleMessage, {
    name: account?.get('display_name'),
  });
  const pageTitleHtml = intl.formatMessage(titleMessage, {
    name: <DisplayNameSimple account={account} />,
  });

  const tabMessage = isOwnCollection
    ? messages.createdByYou
    : messages.createdByAuthor;

  return (
    <Column bindToDocument={!multiColumn} label={pageTitle}>
      <ColumnHeader showBackButton multiColumn={multiColumn} />

      <Scrollable>
        <header className={classes.header}>
          <h1 className={classes.heading}>{pageTitleHtml}</h1>
          <TabList plain>
            <TabLink exact to={`/@${account?.acct}/collections`}>
              {intl.formatMessage(tabMessage, {
                name: <DisplayNameSimple account={account} />,
              })}
            </TabLink>
          </TabList>
        </header>
        {status === 'idle' && (
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
            {showCreateButton && (
              <Link to='/collections/new' className='button button--compact'>
                <Icon id='plus' icon={AddIcon} />
                <FormattedMessage {...editorMessages.newCollection} />
              </Link>
            )}
          </div>
        )}
        <ItemList emptyMessage={emptyMessage} isLoading={status === 'loading'}>
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
      </Scrollable>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
