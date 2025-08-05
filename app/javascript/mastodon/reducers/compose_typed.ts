import { createReducer } from '@reduxjs/toolkit';
import { List as ImmutableList } from 'immutable';

import { quoteComposeById } from '../actions/compose_typed';
import type { StatusVisibility } from '../api_types/statuses';
import type { ApiHashtagJSON } from '../api_types/tags';
import type { CustomEmoji } from '../models/custom_emoji';
import type { MediaAttachment } from '../models/media_attachment';

type SuggestionEmoji = CustomEmoji & { type: 'emoji' };
type SuggestionHashtag = ApiHashtagJSON & { type: 'hashtag' };
interface SuggestionAccount {
  type: 'account';
  id: string;
}
type Suggestion = SuggestionEmoji | SuggestionHashtag | SuggestionAccount;

export interface ComposeShape {
  mounted: number;
  sensitive: boolean;
  spoiler: boolean;
  spoiler_text: string;
  privacy: StatusVisibility | null;
  id: string | null;
  text: string;
  language: string;
  focusDate: Date | null;
  caretPosition: number | null;
  preselectDate: Date | null;
  in_reply_to: string | null;
  is_composing: boolean;
  is_submitting: boolean;
  is_changing_upload: boolean;
  is_uploading: boolean;
  is_processing: boolean;
  should_redirect_to_compose_page: boolean;
  progress: number;
  isUploadingThumbnail: boolean;
  thumbnailProgress: number;
  media_attachments: ImmutableList<MediaAttachment>;
  pending_media_attachments: number;
  poll: ComposePollShape | null;
  suggestion_token: string | null;
  suggestions: ImmutableList<Suggestion>;
  default_privacy: StatusVisibility;
  default_sensitive: boolean;
  default_language: string;
  resetFileKey: number;
  idempotencyKey: string | null;
  tagHistory: ImmutableList<string>;
}

export const initialState: ComposeShape = {
  mounted: 0,
  sensitive: false,
  spoiler: false,
  spoiler_text: '',
  privacy: null,
  id: null,
  text: '',
  language: 'en',
  focusDate: null,
  caretPosition: null,
  preselectDate: null,
  in_reply_to: null,
  is_composing: false,
  is_submitting: false,
  is_changing_upload: false,
  is_uploading: false,
  is_processing: false,
  should_redirect_to_compose_page: false,
  progress: 0,
  isUploadingThumbnail: false,
  thumbnailProgress: 0,
  media_attachments: ImmutableList(),
  pending_media_attachments: 0,
  poll: null,
  suggestion_token: null,
  suggestions: ImmutableList(),
  default_privacy: 'public',
  default_sensitive: false,
  default_language: 'en',
  resetFileKey: Math.floor(Math.random() * 0x10000),
  idempotencyKey: null,
  tagHistory: ImmutableList(),
};

export interface ComposePollShape {
  options: string[];
  expires_in: number;
  multiple: boolean;
}

export const initialPollState = {
  options: ['', ''],
  expires_in: 24 * 3600,
  multiple: false,
} satisfies ComposePollShape;

export const composeReducer = createReducer(initialState, (builder) => {
  builder.addCase(quoteComposeById, (state, action) => {
    state.id = action.payload.toString(); // Temp
  });
});
