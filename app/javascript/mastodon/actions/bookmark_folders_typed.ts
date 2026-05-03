import {
  apiCreateBookmarkFolder,
  apiDeleteBookmarkFolder,
  apiGetBookmarkFolder,
  apiGetBookmarkFolders,
  apiUpdateBookmarkFolder,
} from 'mastodon/api/bookmark_folders';
import type { BookmarkFolder } from 'mastodon/models/bookmark_folder';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const createBookmarkFolder = createDataLoadingThunk(
  'bookmarkFolders/create',
  (folder: Partial<BookmarkFolder>) => apiCreateBookmarkFolder(folder),
);

export const updateBookmarkFolder = createDataLoadingThunk(
  'bookmarkFolders/update',
  (folder: Partial<BookmarkFolder>) => apiUpdateBookmarkFolder(folder),
);

export const fetchBookmarkFolders = createDataLoadingThunk(
  'bookmarkFolders/fetch',
  () => apiGetBookmarkFolders(),
);

export const fetchBookmarkFolder = createDataLoadingThunk(
  'bookmarkFolders/fetchOne',
  ({ id }: { id: string }) => apiGetBookmarkFolder(id),
);

export const deleteBookmarkFolder = createDataLoadingThunk(
  'bookmarkFolders/delete',
  ({ id }: { id: string }) => apiDeleteBookmarkFolder(id).then(() => ({ id })),
);
