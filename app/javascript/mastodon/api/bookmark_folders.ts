import {
  apiRequestDelete,
  apiRequestGet,
  apiRequestPost,
  apiRequestPut,
} from 'mastodon/api';
import type { ApiBookmarkFolderJSON } from 'mastodon/api_types/bookmark_folders';

export const apiCreateBookmarkFolder = (
  folder: Partial<ApiBookmarkFolderJSON>,
) => apiRequestPost<ApiBookmarkFolderJSON>('v1/bookmark_folders', folder);

export const apiUpdateBookmarkFolder = (
  folder: Partial<ApiBookmarkFolderJSON>,
) =>
  apiRequestPut<ApiBookmarkFolderJSON>(
    `v1/bookmark_folders/${folder.id}`,
    folder,
  );

export const apiGetBookmarkFolders = () =>
  apiRequestGet<ApiBookmarkFolderJSON[]>('v1/bookmark_folders');

export const apiGetBookmarkFolder = (id: string) =>
  apiRequestGet<ApiBookmarkFolderJSON>(`v1/bookmark_folders/${id}`);

export const apiDeleteBookmarkFolder = (id: string) =>
  apiRequestDelete(`v1/bookmark_folders/${id}`);
