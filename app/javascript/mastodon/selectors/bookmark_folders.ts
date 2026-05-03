import type { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import type { BookmarkFolder } from 'mastodon/models/bookmark_folder';
import { createAppSelector } from 'mastodon/store';

const getBookmarkFolders = createAppSelector(
  [(state) => state.bookmark_folders],
  (
    folders: ImmutableMap<string, BookmarkFolder | null>,
  ): ImmutableList<BookmarkFolder> =>
    folders.toList().filter((item): item is BookmarkFolder => !!item),
);

export const getOrderedBookmarkFolders = createAppSelector(
  [(state) => getBookmarkFolders(state)],
  (folders) => folders.sort((a, b) => a.title.localeCompare(b.title)).toArray(),
);
