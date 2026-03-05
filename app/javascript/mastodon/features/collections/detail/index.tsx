import { Fragment, useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import { useLocation, useParams } from 'react-router';

import { openModal } from '@/mastodon/actions/modal';
import { useRelationship } from '@/mastodon/hooks/useRelationship';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Account } from 'mastodon/components/account';
import { Avatar } from 'mastodon/components/avatar';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import {
  DisplayName,
  LinkedDisplayName,
} from 'mastodon/components/display_name';
import { IconButton } from 'mastodon/components/icon_button';
import {
  Article,
  ItemList,
  Scrollable,
} from 'mastodon/components/scrollable_list/components';
import { Tag } from 'mastodon/components/tags/tag';
import { useAccount } from 'mastodon/hooks/useAccount';
import { me } from 'mastodon/initial_state';
import { fetchCollection } from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { CollectionMetaData } from './collection_list_item';
import { CollectionMenu } from './collection_menu';
import classes from './styles.module.scss';

const messages = defineMessages({
  empty: {
    id: 'collections.accounts.empty_title',
    defaultMessage: 'This collection is empty',
  },
  loading: {
    id: 'collections.detail.loading',
    defaultMessage: 'Loading collection…',
  },
  share: {
    id: 'collections.detail.share',
    defaultMessage: 'Share this collection',
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

export const AuthorNote: React.FC<{ id: string; previewMode?: boolean }> = ({
  id,
  // When previewMode is enabled, your own display name
  // will not be replaced with "you"
  previewMode = false,
}) => {
  const account = useAccount(id);
  const author = (
    <span className={classes.displayNameWithAvatar}>
      <Avatar size={18} account={account} />
      {previewMode ? (
        <DisplayName account={account} variant='simple' />
      ) : (
        <LinkedDisplayName displayProps={{ account, variant: 'simple' }} />
      )}
    </span>
  );

  const displayAsYou = id === me && !previewMode;

  return (
    <p className={previewMode ? classes.previewAuthorNote : classes.authorNote}>
      {displayAsYou ? (
        <FormattedMessage
          id='collections.detail.curated_by_you'
          defaultMessage='Curated by you'
        />
      ) : (
        <FormattedMessage
          id='collections.detail.curated_by_author'
          defaultMessage='Curated by {author}'
          values={{ author }}
        />
      )}
    </p>
  );
};

const CollectionHeader: React.FC<{ collection: ApiCollectionJSON }> = ({
  collection,
}) => {
  const intl = useIntl();
  const { name, description, tag, account_id } = collection;
  const dispatch = useAppDispatch();

  const handleShare = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'SHARE_COLLECTION',
        modalProps: {
          collection,
        },
      }),
    );
  }, [collection, dispatch]);

  const location = useLocation<{ newCollection?: boolean } | undefined>();
  const wasJustCreated = location.state?.newCollection;
  useEffect(() => {
    if (wasJustCreated) {
      handleShare();
    }
  }, [handleShare, wasJustCreated]);

  return (
    <div className={classes.header}>
      <div className={classes.titleWithMenu}>
        <div className={classes.titleWrapper}>
          {tag && (
            // TODO: Make non-interactive tag component
            <Tag name={tag.name} className={classes.tag} />
          )}
          <h2 className={classes.name}>{name}</h2>
        </div>
        <div className={classes.headerButtonWrapper}>
          <IconButton
            iconComponent={ShareIcon}
            icon='share-icon'
            title={intl.formatMessage(messages.share)}
            className={classes.iconButton}
            onClick={handleShare}
          />
          <CollectionMenu
            context='collection'
            collection={collection}
            className={classes.iconButton}
          />
        </div>
      </div>
      {description && <p className={classes.description}>{description}</p>}
      <AuthorNote id={collection.account_id} />
      <CollectionMetaData
        extended={account_id === me}
        collection={collection}
        className={classes.metaData}
      />
    </div>
  );
};

const AccountItem: React.FC<{
  accountId: string | undefined;
  collectionOwnerId: string;
}> = ({ accountId, collectionOwnerId }) => {
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

  return <Account minimal={withoutButton} withMenu={false} id={accountId} />;
};

export const CollectionDetailPage: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { id } = useParams<{ id?: string }>();
  const collection = useAppSelector((state) =>
    id ? state.collections.collections[id] : undefined,
  );
  const isLoading = !!id && !collection;

  useEffect(() => {
    if (id) {
      void dispatch(fetchCollection({ collectionId: id }));
    }
  }, [dispatch, id]);

  const { items, currentUserInCollection } = getCollectionItems(collection);

  const pageTitle = collection?.name ?? intl.formatMessage(messages.loading);

  return (
    <Column bindToDocument={!multiColumn} label={pageTitle}>
      <ColumnHeader
        showBackButton
        title={pageTitle}
        icon='collection-icon'
        iconComponent={ListAltIcon}
        multiColumn={multiColumn}
      />

      <Scrollable>
        {collection && <CollectionHeader collection={collection} />}
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
                  accountId={currentUserInCollection.account_id}
                  collectionOwnerId={collection.account_id}
                />
              </Article>
              <h3 className={classes.columnSubheading}>
                <FormattedMessage
                  id='collections.detail.other_accounts_in_collection'
                  defaultMessage='Others in this collection:'
                  tagName={Fragment}
                />
              </h3>
            </>
          ) : (
            <h3 className='column-subheading sr-only'>
              {intl.formatMessage(messages.accounts)}
            </h3>
          )}
          {collection &&
            items.map(({ account_id }, index, items) => (
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
        </ItemList>
      </Scrollable>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
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
