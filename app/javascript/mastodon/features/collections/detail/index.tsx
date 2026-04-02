import { useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import { useHistory, useLocation, useParams } from 'react-router';
import { Link } from 'react-router-dom';

import { openModal } from '@/mastodon/actions/modal';
import { useAccountHandle } from '@/mastodon/components/display_name/default';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Callout } from 'mastodon/components/callout';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { DisplayName } from 'mastodon/components/display_name';
import { IconButton } from 'mastodon/components/icon_button';
import { Scrollable } from 'mastodon/components/scrollable_list/components';
import { useAccount } from 'mastodon/hooks/useAccount';
import { domain, me } from 'mastodon/initial_state';
import { fetchCollection } from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { CollectionAccountsList } from './accounts_list';
import { CollectionMenu } from './collection_menu';
import { useConfirmRevoke } from './revoke_collection_inclusion_modal';
import classes from './styles.module.scss';

const messages = defineMessages({
  loading: {
    id: 'collections.detail.loading',
    defaultMessage: 'Loading collection…',
  },
  share: {
    id: 'collections.detail.share',
    defaultMessage: 'Share this collection',
  },
});

export const AuthorNote: React.FC<{ id: string }> = ({ id }) => {
  const account = useAccount(id);
  const authorHandle = useAccountHandle(account, domain);

  if (!account) {
    return null;
  }

  const author = (
    <Link to={`/@${account.acct}`} data-hover-card-account={account.id}>
      {authorHandle}
    </Link>
  );

  return (
    <p className={classes.authorNote}>
      <FormattedMessage
        id='collections.by_account'
        defaultMessage='by {account_handle}'
        values={{
          account_handle: author,
        }}
      />
    </p>
  );
};

export const RevokeControls: React.FC<{
  collection: ApiCollectionJSON;
}> = ({ collection }) => {
  const authorAccount = useAccount(collection.account_id);
  const confirmRevoke = useConfirmRevoke(collection);

  return (
    <Callout
      title={
        <FormattedMessage
          id='collections.detail.you_are_in_this_collection'
          defaultMessage="You're featured in this collection"
        />
      }
      primaryLabel={
        <FormattedMessage
          id='collections.detail.revoke_inclusion'
          defaultMessage='Remove me'
        />
      }
      onPrimary={confirmRevoke}
    >
      <FormattedMessage
        id='collections.detail.author_added_you_on_date'
        defaultMessage='{author} added you on {date}'
        values={{
          author: <DisplayName account={authorAccount} variant='simple' />,
          date: '{date}', // TODO: Data not yet provided by API
        }}
      />
    </Callout>
  );
};

const CollectionHeader: React.FC<{ collection: ApiCollectionJSON }> = ({
  collection,
}) => {
  const intl = useIntl();
  const { name, description, tag, account_id, items } = collection;
  const dispatch = useAppDispatch();
  const history = useHistory();

  const isOwnCollection = account_id === me;
  const currentUserIndex = items.findIndex(
    (account) => account.account_id === me,
  );
  const isCurrentUserInCollection = !isOwnCollection && currentUserIndex > -1;

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
  const isNewCollection = location.state?.newCollection;
  useEffect(() => {
    if (isNewCollection) {
      // Replace with current pathname to clear `newCollection` state
      history.replace(location.pathname);
      handleShare();
    }
  }, [history, handleShare, isNewCollection, location.pathname]);

  return (
    <header className={classes.header}>
      <div className={classes.titleWithMenu}>
        <div className={classes.titleWrapper}>
          {tag && <span className={classes.tag}>#{tag.name}</span>}
          <h2 className={classes.name}>{name}</h2>
          <AuthorNote id={account_id} />
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
      {isCurrentUserInCollection && <RevokeControls collection={collection} />}
    </header>
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

      <Scrollable>
        {collection && <CollectionHeader collection={collection} />}
        <CollectionAccountsList collection={collection} isLoading={isLoading} />
      </Scrollable>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
