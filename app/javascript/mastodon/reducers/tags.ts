import { createReducer } from '@reduxjs/toolkit';

import {
  fetchFollowedHashtags,
  markFollowedHashtagsStale,
} from 'mastodon/actions/tags_typed';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';

export interface TagsQuery {
  tags: string[];
  loading: boolean;
  stale: boolean;
  next: string | undefined;
}

const initialTagsQuery: TagsQuery = {
  tags: [],
  loading: false,
  stale: true,
  next: undefined,
};

const initialState = {
  tagsById: {} as Record<string, ApiHashtagJSON>,
  sidebarList: initialTagsQuery,
  fullList: initialTagsQuery,
};

export const followedTagsReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(fetchFollowedHashtags.pending, (state, action) => {
      const { context } = action.meta.arg;

      if (context === 'sidebar') {
        state.sidebarList.loading = true;
      } else {
        state.fullList.loading = true;
      }
    })
    .addCase(fetchFollowedHashtags.rejected, (state, action) => {
      const { context } = action.meta.arg;

      if (context === 'sidebar') {
        state.sidebarList.loading = false;
      } else {
        state.fullList.loading = false;
      }
    })
    .addCase(markFollowedHashtagsStale, (state) => {
      state.sidebarList.stale = true;
      state.fullList.stale = true;
    })
    .addCase(fetchFollowedHashtags.fulfilled, (state, action) => {
      const { tags, links, replace, context } = action.payload;

      tags.forEach((tag) => {
        state.tagsById[tag.id] = tag;
      });

      function getNewQueryState(prevTagIds: string[]) {
        const next = links.refs.find((link) => link.rel === 'next');
        const newTagIds = tags.map((tag) => tag.id);

        return {
          tags: replace ? newTagIds : [...prevTagIds, ...newTagIds],
          next: next?.uri,
          stale: false,
          loading: false,
        };
      }

      if (context === 'sidebar') {
        const newSidebarList = getNewQueryState(state.sidebarList.tags);
        state.sidebarList = newSidebarList;

        // Pre-populate the full list with sidebar data
        if (state.fullList.tags.length === 0) {
          state.fullList.tags = newSidebarList.tags;
        }
      } else {
        state.fullList = getNewQueryState(state.fullList.tags);
      }
    });
});
