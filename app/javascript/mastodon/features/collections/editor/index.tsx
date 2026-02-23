import { useEffect } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import {
  Switch,
  Route,
  useParams,
  useRouteMatch,
  matchPath,
  useLocation,
} from 'react-router-dom';

import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { fetchCollection } from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { CollectionAccounts } from './accounts';
import { CollectionDetails } from './details';

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

function usePageTitle(id: string | undefined) {
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

export const CollectionEditorPage: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { id } = useParams<{ id?: string }>();
  const { path } = useRouteMatch();
  const collection = useAppSelector((state) =>
    id ? state.collections.collections[id] : undefined,
  );
  const isEditMode = !!id;
  const isLoading = isEditMode && !collection;

  useEffect(() => {
    if (id) {
      void dispatch(fetchCollection({ collectionId: id }));
    }
  }, [dispatch, id]);

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
        ) : (
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
              render={() => <CollectionDetails collection={collection} />}
            />
          </Switch>
        )}
      </div>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
