import { createSlice } from '@reduxjs/toolkit';

import {
  apiDeleteFeaturedTag,
  apiGetCurrentFeaturedTags,
  apiGetTagSuggestions,
  apiPostFeaturedTag,
} from '@/mastodon/api/accounts';
import { hashtagToFeaturedTag } from '@/mastodon/api_types/tags';
import type { ApiFeaturedTagJSON } from '@/mastodon/api_types/tags';
import { createDataLoadingThunk } from '@/mastodon/store/typed_functions';

interface ProfileEditState {
  tags: ApiFeaturedTagJSON[];
  tagSuggestions: ApiFeaturedTagJSON[];
  isLoading: boolean;
  isPending: boolean;
}

const initialState: ProfileEditState = {
  tags: [],
  tagSuggestions: [],
  isLoading: true,
  isPending: false,
};

const profileEditSlice = createSlice({
  name: 'profileEdit',
  initialState,
  reducers: {},
  extraReducers(builder) {
    builder.addCase(fetchSuggestedTags.fulfilled, (state, action) => {
      state.tagSuggestions = action.payload.map(hashtagToFeaturedTag);
      state.isLoading = false;
    });
    builder.addCase(fetchFeaturedTags.fulfilled, (state, action) => {
      state.tags = action.payload;
      state.isLoading = false;
    });

    builder.addCase(addFeaturedTag.pending, (state) => {
      state.isPending = true;
    });
    builder.addCase(addFeaturedTag.rejected, (state) => {
      state.isPending = false;
    });
    builder.addCase(addFeaturedTag.fulfilled, (state, action) => {
      state.tags.push(action.payload);
      state.tagSuggestions = state.tagSuggestions.filter(
        (tag) => tag.name !== action.meta.arg.name,
      );
      state.isPending = false;
    });

    builder.addCase(deleteFeaturedTag.pending, (state) => {
      state.isPending = true;
    });
    builder.addCase(deleteFeaturedTag.rejected, (state) => {
      state.isPending = false;
    });
    builder.addCase(deleteFeaturedTag.fulfilled, (state, action) => {
      state.tags = state.tags.filter((tag) => tag.id !== action.meta.arg.tagId);
      state.isPending = false;
    });
  },
});

export const profileEdit = profileEditSlice.reducer;

export const fetchFeaturedTags = createDataLoadingThunk(
  `${profileEditSlice.name}/fetchFeaturedTags`,
  apiGetCurrentFeaturedTags,
  { useLoadingBar: false },
);

export const fetchSuggestedTags = createDataLoadingThunk(
  `${profileEditSlice.name}/fetchSuggestedTags`,
  apiGetTagSuggestions,
  { useLoadingBar: false },
);

export const addFeaturedTag = createDataLoadingThunk(
  `${profileEditSlice.name}/addFeaturedTag`,
  ({ name }: { name: string }) => apiPostFeaturedTag(name),
);

export const deleteFeaturedTag = createDataLoadingThunk(
  `${profileEditSlice.name}/deleteFeaturedTag`,
  ({ tagId }: { tagId: string }) => apiDeleteFeaturedTag(tagId),
);
