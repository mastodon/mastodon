import { createSlice } from '@reduxjs/toolkit';

import { fetchAccount } from '@/flavours/glitch/actions/accounts';
import {
  apiDeleteFeaturedTag,
  apiDeleteProfileAvatar,
  apiDeleteProfileHeader,
  apiGetCurrentFeaturedTags,
  apiGetProfile,
  apiGetTagSuggestions,
  apiPatchProfile,
  apiPostFeaturedTag,
} from '@/flavours/glitch/api/accounts';
import type { ApiAccountFieldJSON } from '@/flavours/glitch/api_types/accounts';
import type {
  ApiProfileJSON,
  ApiProfileUpdateParams,
} from '@/flavours/glitch/api_types/profile';
import type {
  ApiFeaturedTagJSON,
  ApiHashtagJSON,
} from '@/flavours/glitch/api_types/tags';
import {
  createAppAsyncThunk,
  createAppSelector,
  createDataLoadingThunk,
} from '@/flavours/glitch/store/typed_functions';
import { hashObjectArray } from '@/flavours/glitch/utils/hash';
import type { SnakeToCamelCase } from '@/flavours/glitch/utils/types';

type ProfileData = {
  [Key in keyof Omit<
    ApiProfileJSON,
    'note' | 'fields' | 'featured_tags'
  > as SnakeToCamelCase<Key>]: ApiProfileJSON[Key];
} & {
  bio: ApiProfileJSON['note'];
  fields: FieldData[];
  featuredTags: TagData[];
};

export type FieldData = ApiAccountFieldJSON & { id: string };

export type TagData = {
  [Key in keyof Omit<
    ApiFeaturedTagJSON,
    'statuses_count'
  > as SnakeToCamelCase<Key>]: ApiFeaturedTagJSON[Key];
} & {
  statusesCount: number;
};

export interface ProfileEditState {
  profile?: ProfileData;
  tagSuggestions?: ApiHashtagJSON[];
  isPending: boolean;
}

const initialState: ProfileEditState = {
  isPending: false,
};

const profileEditSlice = createSlice({
  name: 'profileEdit',
  initialState,
  reducers: {},
  extraReducers(builder) {
    builder.addCase(fetchProfile.fulfilled, (state, action) => {
      state.profile = action.payload;
    });
    builder.addCase(fetchSuggestedTags.fulfilled, (state, action) => {
      state.tagSuggestions = action.payload;
    });

    builder.addCase(patchProfile.pending, (state) => {
      state.isPending = true;
    });
    builder.addCase(patchProfile.rejected, (state) => {
      state.isPending = false;
    });
    builder.addCase(patchProfile.fulfilled, (state, action) => {
      state.profile = action.payload;
      state.isPending = false;
    });

    builder.addCase(uploadImage.pending, (state) => {
      state.isPending = true;
    });
    builder.addCase(uploadImage.rejected, (state) => {
      state.isPending = false;
    });
    builder.addCase(uploadImage.fulfilled, (state, action) => {
      state.profile = action.payload;
      state.isPending = false;
    });

    builder.addCase(deleteImage.pending, (state) => {
      state.isPending = true;
    });
    builder.addCase(deleteImage.rejected, (state) => {
      state.isPending = false;
    });
    builder.addCase(deleteImage.fulfilled, (state) => {
      state.isPending = false;
    });

    builder.addCase(addFeaturedTags.pending, (state) => {
      state.isPending = true;
    });
    builder.addCase(addFeaturedTags.rejected, (state) => {
      state.isPending = false;
    });
    builder.addCase(addFeaturedTags.fulfilled, (state, action) => {
      if (!state.profile) {
        return;
      }

      state.profile.featuredTags = [
        ...state.profile.featuredTags,
        ...action.payload.map(transformTag),
      ].toSorted((a, b) => a.name.localeCompare(b.name));
      if (state.tagSuggestions) {
        state.tagSuggestions = state.tagSuggestions.filter(
          (tag) => !action.meta.arg.names.includes(tag.name),
        );
      }
      state.isPending = false;
    });

    builder.addCase(deleteFeaturedTag.pending, (state) => {
      state.isPending = true;
    });
    builder.addCase(deleteFeaturedTag.rejected, (state) => {
      state.isPending = false;
    });
    builder.addCase(deleteFeaturedTag.fulfilled, (state, action) => {
      if (!state.profile) {
        return;
      }

      state.profile.featuredTags = state.profile.featuredTags.filter(
        (tag) => tag.id !== action.meta.arg.tagId,
      );
      state.isPending = false;
    });
  },
});

export const profileEdit = profileEditSlice.reducer;

const transformTag = (result: ApiFeaturedTagJSON): TagData => ({
  id: result.id,
  name: result.name,
  url: result.url,
  statusesCount: Number.parseInt(result.statuses_count),
  lastStatusAt: result.last_status_at,
});

const transformProfile = (result: ApiProfileJSON): ProfileData => ({
  id: result.id,
  displayName: result.display_name,
  bio: result.note,
  fields: hashObjectArray(result.fields),
  avatar: result.avatar,
  avatarStatic: result.avatar_static,
  avatarDescription: result.avatar_description,
  header: result.header,
  headerStatic: result.header_static,
  headerDescription: result.header_description,
  locked: result.locked,
  bot: result.bot,
  hideCollections: result.hide_collections,
  discoverable: result.discoverable,
  indexable: result.indexable,
  showMedia: result.show_media,
  showMediaReplies: result.show_media_replies,
  showFeatured: result.show_featured,
  attributionDomains: result.attribution_domains,
  featuredTags: result.featured_tags.map(transformTag),
});

export const fetchProfile = createDataLoadingThunk(
  `${profileEditSlice.name}/fetchProfile`,
  apiGetProfile,
  transformProfile,
);

export const patchProfile = createDataLoadingThunk(
  `${profileEditSlice.name}/patchProfile`,
  (params: Partial<ApiProfileUpdateParams>) => apiPatchProfile(params),
  (response, { dispatch }) => {
    dispatch(fetchAccount(response.id));
    return transformProfile(response);
  },
  {
    useLoadingBar: false,
    condition(_, { getState }) {
      return !getState().profileEdit.isPending;
    },
  },
);

export type ImageLocation = 'avatar' | 'header';

export const selectImageInfo = createAppSelector(
  [
    (state) => state.profileEdit.profile,
    (_, location: ImageLocation) => location,
  ],
  (profile, location) => {
    if (!profile) {
      return {};
    }

    return {
      src: profile[location],
      static: profile[`${location}Static`],
      alt: profile[`${location}Description`],
    };
  },
);

export const uploadImage = createDataLoadingThunk(
  `${profileEditSlice.name}/uploadImage`,
  (arg: { location: ImageLocation; imageBlob: Blob; altText: string }) => {
    const formData = new FormData();
    formData.append(arg.location, arg.imageBlob);
    if (arg.altText) {
      formData.append(`${arg.location}_description`, arg.altText);
    }

    return apiPatchProfile(formData);
  },
  (response, { dispatch }) => {
    dispatch(fetchAccount(response.id));
    return transformProfile(response);
  },
  {
    useLoadingBar: false,
  },
);

export const deleteImage = createDataLoadingThunk(
  `${profileEditSlice.name}/deleteImage`,
  (arg: { location: ImageLocation }) => {
    if (arg.location === 'avatar') {
      return apiDeleteProfileAvatar();
    } else {
      return apiDeleteProfileHeader();
    }
  },
  async (_, { dispatch, getState }) => {
    await dispatch(fetchProfile());
    const accountId = getState().profileEdit.profile?.id;
    if (accountId) {
      dispatch(fetchAccount(accountId));
    }
  },
  {
    useLoadingBar: false,
  },
);

export const selectFieldById = createAppSelector(
  [(state) => state.profileEdit.profile?.fields, (_, id?: string) => id],
  (fields, fieldId) => {
    if (!fields || !fieldId) {
      return undefined;
    }
    return fields.find((field) => field.id === fieldId) ?? null;
  },
);

export const updateField = createAppAsyncThunk(
  `${profileEditSlice.name}/updateField`,
  async (
    arg: { id?: string; name: string; value: string },
    { getState, dispatch },
  ) => {
    const fields = getState().profileEdit.profile?.fields;
    if (!fields) {
      throw new Error('Profile fields not found');
    }

    const maxFields = getState().server.getIn([
      'server',
      'configuration',
      'accounts',
      'max_fields',
    ]) as number | undefined;
    if (maxFields && fields.length >= maxFields && !arg.id) {
      throw new Error('Maximum number of profile fields reached');
    }

    // Replace the field data if there is an ID, otherwise append a new field.
    const newFields: Pick<ApiAccountFieldJSON, 'name' | 'value'>[] = [];
    for (const field of fields) {
      if (field.id === arg.id) {
        newFields.push({ name: arg.name, value: arg.value });
      } else {
        newFields.push({ name: field.name, value: field.value });
      }
    }
    if (!arg.id) {
      newFields.push({ name: arg.name, value: arg.value });
    }

    await dispatch(
      patchProfile({
        fields_attributes: newFields,
      }),
    );
  },
);

export const removeField = createAppAsyncThunk(
  `${profileEditSlice.name}/removeField`,
  async (arg: { key: string }, { getState, dispatch }) => {
    const fields = getState().profileEdit.profile?.fields;
    if (!fields) {
      throw new Error('Profile fields not found');
    }
    const field = fields.find((f) => f.id === arg.key);
    if (!field) {
      throw new Error('Field not found');
    }
    const newFields = fields
      .filter((f) => f.id !== arg.key)
      .map((f) => ({
        name: f.name,
        value: f.value,
      }));
    await dispatch(
      patchProfile({
        fields_attributes: newFields,
      }),
    );
  },
);

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

export const addFeaturedTags = createDataLoadingThunk(
  `${profileEditSlice.name}/addFeaturedTag`,
  ({ names }: { names: string[] }) =>
    Promise.all(names.map((n) => apiPostFeaturedTag(n))),
  { useLoadingBar: false },
);

export const deleteFeaturedTag = createDataLoadingThunk(
  `${profileEditSlice.name}/deleteFeaturedTag`,
  ({ tagId }: { tagId: string }) => apiDeleteFeaturedTag(tagId),
);
