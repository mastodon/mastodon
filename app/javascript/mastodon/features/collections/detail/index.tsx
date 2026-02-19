import { useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import { useParams } from 'react-router';

import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import { showAlert } from 'mastodon/actions/alerts';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Account } from 'mastodon/components/account';
import { Avatar } from 'mastodon/components/avatar';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { LinkedDisplayName } from 'mastodon/components/display_name';
import { IconButton } from 'mastodon/components/icon_button';
import ScrollableList from 'mastodon/components/scrollable_list';
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

const AuthorNote: React.FC<{ id: string }> = ({ id }) => {
  const account = useAccount(id);
  const author = (
    <span className={classes.displayNameWithAvatar}>
      <Avatar size={18} account={account} />
      <LinkedDisplayName displayProps={{ account, variant: 'simple' }} />
    </span>
  );

  if (id === me) {
    return (
      <p className={classes.authorNote}>
        <FormattedMessage
          id='collections.detail.curated_by_you'
          defaultMessage='Curated by you'
        />
      </p>
    );
  }
  return (
    <p className={classes.authorNote}>
      <FormattedMessage
        id='collections.detail.curated_by_author'
        defaultMessage='Curated by {author}'
        values={{ author }}
      />
    </p>
  );
};

const CollectionHeader: React.FC<{ collection: ApiCollectionJSON }> = ({
  collection,
}) => {
  const intl = useIntl();
  const { name, description, tag } = collection;
  const dispatch = useAppDispatch();

  const handleShare = useCallback(() => {
    dispatch(showAlert({ message: 'Collection sharing not yet implemented' }));
  }, [dispatch]);

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
        extended
        collection={collection}
        className={classes.metaData}
      />
      <h2 className='sr-only'>{intl.formatMessage(messages.accounts)}</h2>
    </div>
  );
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
        {collection?.items.map(({ account_id }) =>
          account_id ? (
            <Account key={account_id} minimal id={account_id} />
          ) : null,
        )}
      </ScrollableList>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
