import { useEffect } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';
import { useParams } from 'react-router';

import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import ScrollableList from 'mastodon/components/scrollable_list';
import { fetchCollection } from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  empty: {
    id: 'collections.accounts.empty_title',
    defaultMessage: 'This collection is empty',
  },
  loading: {
    id: 'collections.detail.loading',
    defaultMessage: 'Loading collection…',
  },
});

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
        emptyMessage={messages.empty}
        showLoading={isLoading}
        bindToDocument={!multiColumn}
      >
        <div>Hello!</div>
      </ScrollableList>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
