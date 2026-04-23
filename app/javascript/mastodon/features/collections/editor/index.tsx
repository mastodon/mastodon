import { useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import {
  Switch,
  Route,
  useParams,
  useRouteMatch,
  matchPath,
  useLocation,
} from 'react-router-dom';

import { Callout } from '@/mastodon/components/callout';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { initialState } from '@/mastodon/initial_state';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import {
  collectionEditorActions,
  fetchCollection,
} from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { useAccountCollections } from '..';

import { CollectionAccounts } from './accounts';
import { CollectionDetails } from './details';
import classes from './styles.module.scss';

export const messages = defineMessages({
  create: {
    id: 'collections.create_collection',
    defaultMessage: 'Create collection',
  },
  newCollection: {
    id: 'collections.new_collection',
    defaultMessage: 'New collection',
  },
  editDetails: {
    id: 'collections.edit_details',
    defaultMessage: 'Edit details',
  },
  manageAccounts: {
    id: 'collections.manage_accounts',
    defaultMessage: 'Manage accounts',
  },
});

function usePageTitle(id: string | null) {
  const { path } = useRouteMatch();
  const location = useLocation();

  if (!id) {
    return messages.newCollection;
  }

  if (matchPath(location.pathname, { path, exact: true })) {
    return messages.manageAccounts;
  } else if (matchPath(location.pathname, { path: `${path}/details` })) {
    return messages.editDetails;
  } else {
    throw new Error('No page title defined for route');
  }
}

export const userCollectionLimit = initialState?.role?.collection_limit ?? 0;

export const CollectionEditorPage: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const accountId = useCurrentAccountId();
  const { id = null } = useParams<{ id?: string }>();
  const { path } = useRouteMatch();
  const collection = useAppSelector((state) =>
    id ? state.collections.collections[id] : undefined,
  );
  const editorStateId = useAppSelector((state) => state.collections.editor.id);
  const isEditMode = !!id;

  // When creating a new collection, we load the current account's collections
  // to determine if they're allowed to create more.
  const { collections: collectionList, status: collectionListStatus } =
    useAccountCollections(isEditMode ? null : accountId);

  const isLoading =
    (isEditMode && !collection) ||
    (!isEditMode && collectionListStatus === 'loading');

  const canCreateMoreCollections =
    isEditMode || collectionList.length < userCollectionLimit;

  useEffect(() => {
    if (id) {
      void dispatch(fetchCollection({ collectionId: id }));
    }
  }, [dispatch, id]);

  useEffect(() => {
    if (id !== editorStateId) {
      void dispatch(collectionEditorActions.reset());
    }
  }, [dispatch, editorStateId, id]);

  useEffect(() => {
    if (collection) {
      void dispatch(collectionEditorActions.init(collection));
    }
  }, [dispatch, collection]);

  const pageTitle = intl.formatMessage(usePageTitle(id));

  return (
    <Column bindToDocument={!multiColumn} label={pageTitle}>
      <ColumnHeader
        title={pageTitle}
        icon='list-ul'
        iconComponent={ListAltIcon}
        multiColumn={multiColumn}
        showBackButton
      />

      <div className='scrollable'>
        {isLoading ? (
          <LoadingIndicator />
        ) : canCreateMoreCollections ? (
          <Switch>
            <Route
              exact
              path={path}
              // eslint-disable-next-line react/jsx-no-bind
              render={() => <CollectionAccounts collection={collection} />}
            />
            <Route
              exact
              path={`${path}/details`}
              // eslint-disable-next-line react/jsx-no-bind
              render={() => <CollectionDetails />}
            />
          </Switch>
        ) : (
          <MaxCollectionsCallout />
        )}
      </div>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

export const MaxCollectionsCallout: React.FC = () => (
  <Callout
    className={classes.maxCollectionsError}
    title={
      <FormattedMessage
        id='collections.maximum_collection_count_reached'
        defaultMessage='You have created the maximum number of collections'
      />
    }
  >
    <FormattedMessage
      id='collections.maximum_collection_count_description'
      defaultMessage='Your server allows creation of up to {count} collections.'
      values={{ count: userCollectionLimit }}
    />
  </Callout>
);
