import { useEffect, useState } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import BookmarksActiveIcon from '@/material-icons/400-24px/bookmarks-fill.svg?react';
import BookmarksIcon from '@/material-icons/400-24px/bookmarks.svg?react';
import { fetchBookmarkFolders } from 'mastodon/actions/bookmark_folders_typed';
import { ColumnLink } from 'mastodon/features/ui/components/column_link';
import { getOrderedBookmarkFolders } from 'mastodon/selectors/bookmark_folders';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { CollapsiblePanel } from './collapsible_panel';

const messages = defineMessages({
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
  expand: {
    id: 'navigation_panel.expand_bookmark_folders',
    defaultMessage: 'Expand bookmark folders',
  },
  collapse: {
    id: 'navigation_panel.collapse_bookmark_folders',
    defaultMessage: 'Collapse bookmark folders',
  },
});

export const BookmarkFoldersPanel: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const folders = useAppSelector((state) => getOrderedBookmarkFolders(state));
  const [loading, setLoading] = useState(true);
  const hasFolders = folders.length > 0;
  const allBookmarksLink = hasFolders ? (
    <ColumnLink
      icon='bookmarks'
      iconComponent={BookmarksIcon}
      activeIconComponent={BookmarksActiveIcon}
      text={intl.formatMessage({
        id: 'bookmarks.all',
        defaultMessage: 'All Bookmarks',
      })}
      to='/bookmarks'
      exact
      transparent
    />
  ) : null;
  const folderLinks = hasFolders
    ? folders.map((folder) => (
        <ColumnLink
          icon='bookmarks'
          key={folder.id}
          iconComponent={BookmarksIcon}
          activeIconComponent={BookmarksActiveIcon}
          text={folder.title}
          to={`/bookmarks/folders/${folder.id}`}
          transparent
        />
      ))
    : null;

  useEffect(() => {
    void dispatch(fetchBookmarkFolders()).then(() => {
      setLoading(false);

      return '';
    });
  }, [dispatch]);

  return (
    <CollapsiblePanel
      to={hasFolders ? '/bookmarks/folders' : '/bookmarks'}
      activePath={
        hasFolders ? ['/bookmarks', '/bookmarks/folders'] : '/bookmarks'
      }
      icon='bookmarks'
      iconComponent={BookmarksIcon}
      activeIconComponent={BookmarksActiveIcon}
      title={intl.formatMessage(messages.bookmarks)}
      collapseTitle={intl.formatMessage(messages.collapse)}
      expandTitle={intl.formatMessage(messages.expand)}
      loading={loading}
    >
      {allBookmarksLink}
      {folderLinks}
    </CollapsiblePanel>
  );
};
