import { createReducer } from '@reduxjs/toolkit';

import {
  fetchFollowedHashtags,
  markFollowedHashtagsStale,
  unfollowHashtag,
} from 'mastodon/actions/tags_typed';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';

export interface TagsQuery {
  tags: ApiHashtagJSON[];
  loading: boolean;
  stale: boolean;
  next: string | undefined;
}

const initialState: TagsQuery = {
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
    .addCase(markFollowedHashtagsStale, (state) => {
      state.stale = true;
    })
    .addCase(unfollowHashtag.fulfilled, (state, action) => {
      const tagId = action.payload.id;
      state.tags = state.tags.filter((tag) => tag.id !== tagId);
    })
    .addCase(fetchFollowedHashtags.fulfilled, (state, action) => {
      const { tags, links, replace } = action.payload;
      const next = links.refs.find((link) => link.rel === 'next');

      state.tags = replace ? tags : [...state.tags, ...tags];
      state.next = next?.uri;
      state.stale = false;
      state.loading = false;
    });
});
