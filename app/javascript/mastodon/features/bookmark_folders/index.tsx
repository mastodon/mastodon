import { useEffect, useMemo, useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { Helmet } from '@unhead/react/helmet';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import BookmarksIcon from '@/material-icons/400-24px/bookmarks.svg?react';
import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { fetchBookmarkFolders } from 'mastodon/actions/bookmark_folders_typed';
import { openModal } from 'mastodon/actions/modal';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { Icon } from 'mastodon/components/icon';
import ScrollableList from 'mastodon/components/scrollable_list';
import { getOrderedBookmarkFolders } from 'mastodon/selectors/bookmark_folders';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  heading: {
    id: 'column.bookmark_folders',
    defaultMessage: 'Bookmark folders',
  },
  create: { id: 'bookmark_folders.create', defaultMessage: 'Create folder' },
  edit: { id: 'bookmark_folders.edit', defaultMessage: 'Edit folder' },
  delete: { id: 'bookmark_folders.delete', defaultMessage: 'Delete folder' },
  more: { id: 'status.more', defaultMessage: 'More' },
});

const FolderItem: React.FC<{
  id: string;
  title: string;
}> = ({ id, title }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const handleDeleteClick = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'CONFIRM_DELETE_BOOKMARK_FOLDER',
        modalProps: { id },
      }),
    );
  }, [dispatch, id]);

  const menu = useMemo(
    () => [
      {
        text: intl.formatMessage(messages.edit),
        to: `/bookmarks/folders/${id}/edit`,
      },
      { text: intl.formatMessage(messages.delete), action: handleDeleteClick },
    ],
    [intl, id, handleDeleteClick],
  );

  return (
    <div className='lists__item'>
      <Link to={`/bookmarks/folders/${id}`} className='lists__item__title'>
        <Icon id='bookmarks' icon={BookmarksIcon} />
        <span>{title}</span>
      </Link>

      <Dropdown
        scrollKey='bookmark_folders'
        items={menu}
        icon='ellipsis-h'
        iconComponent={MoreHorizIcon}
        title={intl.formatMessage(messages.more)}
      />
    </div>
  );
};

const AllBookmarksItem: React.FC = () => {
  const intl = useIntl();

  return (
    <div className='lists__item'>
      <Link to='/bookmarks' className='lists__item__title'>
        <Icon id='bookmarks' icon={BookmarksIcon} />
        <span>
          {intl.formatMessage({
            id: 'bookmarks.all',
            defaultMessage: 'All Bookmarks',
          })}
        </span>
      </Link>
    </div>
  );
};

const BookmarkFolders: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const folders = useAppSelector((state) => getOrderedBookmarkFolders(state));

  useEffect(() => {
    void dispatch(fetchBookmarkFolders());
  }, [dispatch]);

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.heading)}
    >
      <ColumnHeader
        title={intl.formatMessage(messages.heading)}
        icon='bookmarks'
        iconComponent={BookmarksIcon}
        multiColumn={multiColumn}
        extraButton={
          <Link
            to='/bookmarks/folders/new'
            className='column-header__button'
            title={intl.formatMessage(messages.create)}
            aria-label={intl.formatMessage(messages.create)}
          >
            <Icon id='plus' icon={AddIcon} />
          </Link>
        }
      />

      <ScrollableList
        scrollKey='bookmark_folders'
        bindToDocument={!multiColumn}
      >
        <AllBookmarksItem />
        {folders.map((folder) => (
          <FolderItem key={folder.id} id={folder.id} title={folder.title} />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.heading)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default BookmarkFolders;
