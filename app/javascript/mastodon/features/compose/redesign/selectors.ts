import { length } from 'stringz';

import type { StatusVisibility } from '@/mastodon/models/status';
import { createAppSelector } from '@/mastodon/store';

import { countableText } from '../util/counter';

export type ComposeType = 'post' | 'message' | 'reply';

export const selectComposeType = createAppSelector(
  [
    (state) => state.compose.get('in_reply_to') as string | null,
    (state) =>
      (state.compose.get('privacy') as StatusVisibility | null) ??
      (state.compose.get('default_privacy') as StatusVisibility),
  ],
  (inReplyToId, privacy) => {
    let type: ComposeType = 'post';
    if (inReplyToId) {
      type = 'reply';
    } else if (privacy === 'direct') {
      type = 'message';
    }

    return type;
  },
);

export const selectComposeCharsCount = createAppSelector(
  [
    (state) => state.server.server.item?.configuration.statuses.max_characters,
    (state) => state.compose.get('text') as string,
    (state) =>
      state.compose.get('spoiler')
        ? (state.compose.get('spoiler_text') as string)
        : '',
  ],
  (maxChars, text, spoilerText) => {
    const allText = (countableText(text) as string) + spoilerText;
    return {
      text: allText,
      current: length(allText),
      max: maxChars ?? 500,
    };
  },
);

export const selectComposeCanSubmit = createAppSelector(
  [
    (state) => !!state.compose.get('is_submitting'),
    (state) => !!state.compose.get('is_uploading'),
    (state) => !!state.compose.get('is_changing_upload'),
    selectComposeCharsCount,
  ],
  (isSubmitting, isUploading, isChangingUpload, { current, max }) =>
    !isSubmitting && !isUploading && !isChangingUpload && current <= max,
);

export const selectComposeState = createAppSelector(
  [(state) => state.compose, selectComposeType, selectComposeCanSubmit],
  (compose, type, canSubmit) => ({
    type,
    text: compose.get('text') as string,
    sensitive: !!compose.get('spoiler'),
    sensitiveText: compose.get('spoiler_text') as string,
    lang: compose.get('language') as string,
    suggestions: compose.get(
      'suggestions',
    ) as unknown as Immutable.List<unknown>,
    canSubmit,
    isSubmitting: !!compose.get('is_submitting'),
  }),
);
