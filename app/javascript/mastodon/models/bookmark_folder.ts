import type { RecordOf } from 'immutable';
import { Record } from 'immutable';

import type { ApiBookmarkFolderJSON } from 'mastodon/api_types/bookmark_folders';

type BookmarkFolderShape = Required<ApiBookmarkFolderJSON>;
export type BookmarkFolder = RecordOf<BookmarkFolderShape>;

const BookmarkFolderFactory = Record<BookmarkFolderShape>({
  id: '',
  title: '',
});

export function createBookmarkFolder(attributes: Partial<BookmarkFolderShape>) {
  return BookmarkFolderFactory(attributes);
}
