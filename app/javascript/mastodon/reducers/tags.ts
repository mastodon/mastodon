import { createReducer } from '@reduxjs/toolkit';

import {
  fetchFollowedHashtags,
  markFollowedHashtagsStale,
} from 'mastodon/actions/tags_typed';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';

const initialState: {
  tags: ApiHashtagJSON[];
  loading: boolean;
  stale: boolean;
  next: string | undefined;
} = {
  tags: [],
  loading: false,
  stale: true,
  next: undefined,
};

export const followedTagsReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(fetchFollowedHashtags.pending, (state) => {
      state.loading = true;
    })
    .addCase(fetchFollowedHashtags.rejected, (state) => {
      state.loading = false;
    })
    .addCase(
      fetchFollowedHashtags.fulfilled,
      (state, { payload: { tags, links, replace } }) => {
        const next = links.refs.find((link) => link.rel === 'next');

        if (replace) {
          state.tags = tags;
        } else {
          const newTagsById = new Map(tags.map((tag) => [tag.id, tag]));

          // Update existing items if needed
          const updatedTags = state.tags
            .map((item) =>
              newTagsById.has(item.id) ? newTagsById.get(item.id) : item,
            )
            .filter((item) => !!item);

          // Add new items
          const existingIds = new Set(state.tags.map((item) => item.id));
          const newItems = tags.filter((tag) => !existingIds.has(tag.id));

          state.tags = [...updatedTags, ...newItems];
        }
        state.next = next?.uri;
        state.stale = false;
        state.loading = false;
      },
    )
    .addCase(markFollowedHashtagsStale, (state) => {
      state.stale = true;
    });
});
