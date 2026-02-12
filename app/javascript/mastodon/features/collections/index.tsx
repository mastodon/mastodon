import { useEffect, useMemo, useCallback, useId } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import SquigglyArrow from '@/svg-icons/squiggly_arrow.svg?react';
import { openModal } from 'mastodon/actions/modal';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { Icon } from 'mastodon/components/icon';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import ScrollableList from 'mastodon/components/scrollable_list';
import {
  fetchAccountCollections,
  selectMyCollections,
} from 'mastodon/reducers/slices/collections';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { messages as editorMessages } from './editor';
import classes from './styles.module.scss';

const messages = defineMessages({
  heading: { id: 'column.collections', defaultMessage: 'My collections' },
  view: {
    id: 'collections.view_collection',
    defaultMessage: 'View collection',
  },
  delete: {
    id: 'collections.delete_collection',
    defaultMessage: 'Delete collection',
  },
  more: { id: 'status.more', defaultMessage: 'More' },
});

const CollectionItem: React.FC<{
  collection: ApiCollectionJSON;
}> = ({ collection }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const { id, name } = collection;

  const handleDeleteClick = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'CONFIRM_DELETE_COLLECTION',
        modalProps: {
          name,
          id,
        },
      }),
    );
  }, [dispatch, id, name]);

  const menu = useMemo(
    () => [
      { text: intl.formatMessage(messages.view), to: `/collections/${id}` },
      null,
      {
        text: intl.formatMessage(editorMessages.manageAccounts),
        to: `/collections/${id}/edit`,
      },
      {
        text: intl.formatMessage(editorMessages.editDetails),
        to: `/collections/${id}/edit/details`,
      },
      {
        text: intl.formatMessage(editorMessages.editSettings),
        to: `/collections/${id}/edit/settings`,
      },
      null,
      {
        text: intl.formatMessage(messages.delete),
        action: handleDeleteClick,
        dangerous: true,
      },
    ],
    [intl, id, handleDeleteClick],
  );

  const linkId = useId();

  return (
    <article
      className={classNames(classes.collectionItemWrapper, 'focusable')}
      tabIndex={-1}
      aria-labelledby={linkId}
    >
      <div className={classes.collectionItemContent}>
        <h2 id={linkId}>
          <Link
            to={`/collections/${id}/edit/details`}
            className={classes.collectionItemLink}
          >
            {name}
          </Link>
        </h2>
        <ul className={classes.collectionItemInfo}>
          <FormattedMessage
            id='collections.account_count'
            defaultMessage='{count, plural, one {# account} other {# accounts}}'
            values={{ count: collection.item_count }}
            tagName='li'
          />
          <FormattedMessage
            id='collections.last_updated_at'
            defaultMessage='Last updated: {date}'
            values={{
              date: (
                <RelativeTimestamp
                  timestamp={collection.updated_at}
                  short={false}
                />
              ),
            }}
            tagName='li'
          />
        </ul>
      </div>

      <Dropdown
        scrollKey='collections'
        items={menu}
        icon='ellipsis-h'
        iconComponent={MoreHorizIcon}
        title={intl.formatMessage(messages.more)}
      />
    </article>
  );
};

export const Collections: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const me = useAppSelector((state) => state.meta.get('me') as string);
  const { collections, status } = useAppSelector(selectMyCollections);

  useEffect(() => {
    void dispatch(fetchAccountCollections({ accountId: me }));
  }, [dispatch, me]);

  const emptyMessage =
    status === 'error' ? (
      <FormattedMessage
        id='collections.error_loading_collections'
        defaultMessage='There was an error when trying to load your collections.'
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

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.heading)}
    >
      <ColumnHeader
        title={intl.formatMessage(messages.heading)}
        icon='list-ul'
        iconComponent={ListAltIcon}
        multiColumn={multiColumn}
        extraButton={
          <Link
            to='/collections/new'
            className='column-header__button'
            title={intl.formatMessage(editorMessages.create)}
            aria-label={intl.formatMessage(editorMessages.create)}
          >
            <Icon id='plus' icon={AddIcon} />
          </Link>
        }
      />

      <ScrollableList
        scrollKey='collections'
        emptyMessage={emptyMessage}
        isLoading={status === 'loading'}
        bindToDocument={!multiColumn}
      >
        {collections.map((item) => (
          <CollectionItem key={item.id} collection={item} />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.heading)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
