import { useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import { useLocation, useParams } from 'react-router';

import { openModal } from '@/flavours/glitch/actions/modal';
import { useRelationship } from '@/flavours/glitch/hooks/useRelationship';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import type { ApiCollectionJSON } from 'flavours/glitch/api_types/collections';
import { Account } from 'flavours/glitch/components/account';
import { Avatar } from 'flavours/glitch/components/avatar';
import { Column } from 'flavours/glitch/components/column';
import { ColumnHeader } from 'flavours/glitch/components/column_header';
import {
  DisplayName,
  LinkedDisplayName,
} from 'flavours/glitch/components/display_name';
import { IconButton } from 'flavours/glitch/components/icon_button';
import ScrollableList from 'flavours/glitch/components/scrollable_list';
import { Tag } from 'flavours/glitch/components/tags/tag';
import { useAccount } from 'flavours/glitch/hooks/useAccount';
import { me } from 'flavours/glitch/initial_state';
import { fetchCollection } from 'flavours/glitch/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'flavours/glitch/store';

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

  const location = useLocation<{ newCollection?: boolean }>();
  const wasJustCreated = location.state.newCollection;
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
      <h2 className='sr-only'>{intl.formatMessage(messages.accounts)}</h2>
    </div>
  );
};

const CollectionAccountItem: React.FC<{
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

      <ScrollableList
        scrollKey='collection-detail'
        emptyMessage={intl.formatMessage(messages.empty)}
        showLoading={isLoading}
        bindToDocument={!multiColumn}
        alwaysPrepend
        prepend={
          collection ? <CollectionHeader collection={collection} /> : null
        }
      >
        {collection?.items.map(({ account_id }) => (
          <CollectionAccountItem
            key={account_id}
            accountId={account_id}
            collectionOwnerId={collection.account_id}
          />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
