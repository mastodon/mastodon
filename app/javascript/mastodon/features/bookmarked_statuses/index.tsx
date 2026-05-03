import { useEffect, useRef, useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Link, useParams } from 'react-router-dom';

import { Helmet } from '@unhead/react/helmet';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import BookmarksIcon from '@/material-icons/400-24px/bookmarks-fill.svg?react';
import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import { fetchBookmarkFolders } from 'mastodon/actions/bookmark_folders_typed';
import {
  fetchBookmarkedStatuses,
  expandBookmarkedStatuses,
} from 'mastodon/actions/bookmarks';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { openModal } from 'mastodon/actions/modal';
import { Column } from 'mastodon/components/column';
import type { ColumnRef } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Icon } from 'mastodon/components/icon';
import StatusList from 'mastodon/components/status_list';
import { getStatusList } from 'mastodon/selectors';
import { getOrderedBookmarkFolders } from 'mastodon/selectors/bookmark_folders';
import { getBookmarkFolderStatusList } from 'mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  heading: { id: 'column.bookmarks', defaultMessage: 'Bookmarks' },
  allBookmarks: { id: 'bookmarks.all', defaultMessage: 'All Bookmarks' },
  createFolder: {
    id: 'bookmark_folders.create',
    defaultMessage: 'Create folder',
  },
});

const Bookmarks: React.FC<{
  columnId: string;
  multiColumn: boolean;
}> = ({ columnId, multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const columnRef = useRef<ColumnRef>(null);
  const { folderId } = useParams<{ folderId?: string }>();
  const statusIds = useAppSelector((state) =>
    folderId
      ? getBookmarkFolderStatusList(state, folderId)
      : getStatusList(state, 'bookmarks'),
  );
  const folders = useAppSelector((state) => getOrderedBookmarkFolders(state));
  const isLoading = useAppSelector(
    (state) =>
      (folderId
        ? state.status_lists.getIn(
            ['bookmark_folders', folderId, 'isLoading'],
            true,
          )
        : state.status_lists.getIn(
            ['bookmarks', 'isLoading'],
            true,
          )) as boolean,
  );
  const hasMore = useAppSelector(
    (state) =>
      !!(folderId
        ? state.status_lists.getIn(['bookmark_folders', folderId, 'next'])
        : state.status_lists.getIn(['bookmarks', 'next'])),
  );

  useEffect(() => {
    dispatch(fetchBookmarkedStatuses(folderId));
  }, [dispatch, folderId]);

  useEffect(() => {
    void dispatch(fetchBookmarkFolders());
  }, [dispatch]);

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('BOOKMARKS', {}));
    }
  }, [dispatch, columnId]);

  const handleMove = useCallback(
    (dir: number) => {
      dispatch(moveColumn(columnId, dir));
    },
    [dispatch, columnId],
  );

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  const handleDeleteClick = useCallback(() => {
    if (folderId) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_DELETE_BOOKMARK_FOLDER',
          modalProps: { id: folderId },
        }),
      );
    }
  }, [dispatch, folderId]);

  const handleLoadMore = useCallback(() => {
    dispatch(expandBookmarkedStatuses(folderId));
  }, [dispatch, folderId]);

  const pinned = !!columnId;
  const currentFolder = folderId
    ? folders.find((folder) => folder.id === folderId)
    : null;
  const currentFolderLabel = folderId
    ? (currentFolder?.title ?? folderId)
    : intl.formatMessage(messages.allBookmarks);

  const emptyMessage = folderId ? (
    <FormattedMessage
      id='empty_column.bookmark_folder'
      defaultMessage='No bookmarks in this folder yet.'
    />
  ) : (
    <FormattedMessage
      id='empty_column.bookmarked_statuses'
      defaultMessage="You don't have any bookmarked posts yet. When you bookmark one, it will show up here."
    />
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={currentFolderLabel}
    >
      <ColumnHeader
        icon='bookmarks'
        iconComponent={BookmarksIcon}
        title={currentFolderLabel}
        onPin={handlePin}
        onMove={handleMove}
        onClick={handleHeaderClick}
        pinned={pinned}
        multiColumn={multiColumn}
        extraButton={
          !folderId ? (
            <Link
              to='/bookmarks/folders/new'
              className='column-header__button'
              title={intl.formatMessage(messages.createFolder)}
              aria-label={intl.formatMessage(messages.createFolder)}
            >
              <Icon id='plus' icon={AddIcon} />
            </Link>
          ) : null
        }
      >
        {folderId && (
          <div className='column-settings'>
            <section className='column-header__links'>
              <Link
                to={`/bookmarks/folders/${folderId}/edit`}
                className='text-btn column-header__setting-btn'
              >
                <Icon id='pencil' icon={EditIcon} />{' '}
                <FormattedMessage
                  id='bookmark_folders.edit'
                  defaultMessage='Edit folder'
                />
              </Link>

              <button
                type='button'
                className='text-btn column-header__setting-btn'
                tabIndex={0}
                onClick={handleDeleteClick}
              >
                <Icon id='trash' icon={DeleteIcon} />{' '}
                <FormattedMessage
                  id='bookmark_folders.delete'
                  defaultMessage='Delete folder'
                />
              </button>
            </section>
          </div>
        )}
      </ColumnHeader>

      <StatusList
        trackScroll={!pinned}
        statusIds={statusIds}
        scrollKey={`bookmarked_statuses-${folderId ?? 'all'}-${columnId}`}
        hasMore={hasMore}
        isLoading={isLoading}
        onLoadMore={handleLoadMore}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
        timelineId='bookmarks'
      />

      <Helmet>
        <title>
          {folderId
            ? `${currentFolderLabel} - ${intl.formatMessage(messages.heading)}`
            : currentFolderLabel}
        </title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Bookmarks;
