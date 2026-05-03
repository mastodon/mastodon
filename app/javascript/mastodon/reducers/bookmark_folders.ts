import type { Reducer } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';

import {
  createBookmarkFolder,
  deleteBookmarkFolder,
  fetchBookmarkFolder,
  fetchBookmarkFolders,
  updateBookmarkFolder,
} from 'mastodon/actions/bookmark_folders_typed';
import type { ApiBookmarkFolderJSON } from 'mastodon/api_types/bookmark_folders';
import { createBookmarkFolder as createBookmarkFolderFromJSON } from 'mastodon/models/bookmark_folder';
import type { BookmarkFolder } from 'mastodon/models/bookmark_folder';

const initialState = ImmutableMap<string, BookmarkFolder | null>();
type State = typeof initialState;

const normalizeFolder = (state: State, folder: ApiBookmarkFolderJSON) =>
  state.set(folder.id, createBookmarkFolderFromJSON(folder));

const normalizeFolders = (state: State, folders: ApiBookmarkFolderJSON[]) => {
  folders.forEach((folder) => {
    state = normalizeFolder(state, folder);
  });

  return state;
};

export const bookmarkFoldersReducer: Reducer<State> = (
  state = initialState,
  action,
) => {
  if (
    createBookmarkFolder.fulfilled.match(action) ||
    updateBookmarkFolder.fulfilled.match(action)
  ) {
    return normalizeFolder(state, action.payload);
  }

  if (fetchBookmarkFolder.fulfilled.match(action))
    return normalizeFolder(state, action.payload);

  if (fetchBookmarkFolders.fulfilled.match(action))
    return normalizeFolders(state, action.payload);

  if (deleteBookmarkFolder.fulfilled.match(action))
    return state.delete(action.payload.id);

  return state;
};
