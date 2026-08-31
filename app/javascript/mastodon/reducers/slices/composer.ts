import { createSlice } from '@reduxjs/toolkit';

import {
  changeCompose,
  clearComposeSuggestions,
  directCompose,
  replyComposeById,
  resetCompose,
  submitCompose,
} from '@/mastodon/actions/compose';
import {
  changeComposeVisibility,
  PRIVATE_QUOTE_MODAL_ID,
} from '@/mastodon/actions/compose_typed';
import { openModal } from '@/mastodon/actions/modal';
import type {
  ApiStatusJSON,
  StatusVisibility,
} from '@/mastodon/api_types/statuses';
import {
  createAppSelector,
  createAppThunk,
} from '@/mastodon/store/typed_functions';

export const COMPOSER_TEXTAREA_ID = 'composer-text';
export function getComposerTextarea() {
  const textarea = document.getElementById(COMPOSER_TEXTAREA_ID);
  if (textarea instanceof HTMLTextAreaElement) {
    return textarea;
  }
  return null;
}
/**
 * Focuses on the composer textarea.
 * @param defer Waits before focusing. Useful if the composer may not be focusable immediately.
 */
export function focusComposerTextarea(defer = false) {
  if (defer) {
    requestAnimationFrame(() => {
      getComposerTextarea()?.focus();
    });
  } else {
    getComposerTextarea()?.focus();
  }
}

type DisplayState = 'hidden' | 'showing' | 'minimized';

export type ComposeType = 'post' | 'message' | 'reply';

interface ComposerState {
  displayState: DisplayState;
}

const initialState: ComposerState = {
  displayState: 'hidden',
};

const composerSlice = createSlice({
  name: 'composer',
  initialState,
  reducers: {
    showComposer(state) {
      state.displayState = 'showing';
    },
    minimizeComposerToggle(state) {
      state.displayState =
        state.displayState === 'showing' ? 'minimized' : 'showing';
    },
    hideComposer(state) {
      state.displayState = 'hidden';
    },
  },
});

export const composer = composerSlice.reducer;

export const minimizeComposerToggle = createAppThunk(
  (_arg, { dispatch, getState }) => {
    dispatch(composerSlice.actions.minimizeComposerToggle());

    const displayState = getState().composer.displayState;
    if (displayState !== 'showing') {
      dispatch(clearComposeSuggestions());
    }
  },
);

export const selectComposerIsChanged = createAppSelector(
  [
    (state) => state.compose.get('text') as string,
    (state) => state.compose.get('spoiler_text') as string,
    (state) => !!state.compose.get('poll'),
    (state) => !!state.compose.get('quoted_status_id'),
    (state) =>
      state.compose.get(
        'media_attachments',
      ) as unknown as Immutable.List<unknown>,
    (state) => Number(state.compose.get('pending_media_attachments')),
  ],
  (text, spoilerText, hasPoll, hasQuote, attachments, pendingAttachmentsNum) =>
    text.trim().length > 0 ||
    spoilerText.trim().length > 0 ||
    hasPoll ||
    hasQuote ||
    attachments.size > 0 ||
    pendingAttachmentsNum > 0,
);

interface ComposeNewPost {
  type?: 'post';
}
interface ComposeNewReply {
  type: 'reply';
  toStatusId: string;
}
interface ComposeNewMessage {
  type: 'message';
  toAccountId?: string;
}
type ComposeNewPayload = (
  | ComposeNewPost
  | ComposeNewReply
  | ComposeNewMessage
) & { force?: boolean };

export const openNewComposer = createAppThunk(
  (payload: ComposeNewPayload, { dispatch, getState }) => {
    if (!payload.force && selectComposerIsChanged(getState())) {
      dispatch(
        openModal({
          modalType: 'COMPOSER_DRAFT_DELETE',
          modalProps: {
            openNew: true,
          },
        }),
      );
      return;
    }

    dispatch(resetCompose());
    if (payload.type === 'message') {
      const account =
        !!payload.toAccountId && getState().accounts.get(payload.toAccountId);
      if (account) {
        dispatch(directCompose(account));
      } else {
        dispatch(changeComposeVisibility('direct'));
      }
    } else if (payload.type === 'reply') {
      dispatch(replyComposeById(payload.toStatusId));
    }
    dispatch(composerSlice.actions.showComposer());

    focusComposerTextarea(true);
  },
);

export const resetComposer = createAppThunk((_arg, { dispatch }) => {
  dispatch(composerSlice.actions.hideComposer());
  dispatch(resetCompose());
  dispatch(clearComposeSuggestions());
});

export const closeComposer = createAppThunk((_arg, { getState, dispatch }) => {
  const isChanged = selectComposerIsChanged(getState());

  if (!isChanged) {
    dispatch(resetComposer());
  } else {
    dispatch(
      openModal({
        modalType: 'COMPOSER_DRAFT_DELETE',
        modalProps: {},
      }),
    );
  }
});

export const newComposer = createAppThunk((_arg, { getState, dispatch }) => {
  const isChanged = selectComposerIsChanged(getState());

  if (!isChanged) {
    dispatch(resetComposer());
  } else {
    dispatch(
      openModal({
        modalType: 'COMPOSER_DRAFT_DELETE',
        modalProps: {},
      }),
    );
  }
});

export const selectIsMinimized = createAppSelector(
  [(state) => state.composer.displayState],
  (displayState) => displayState === 'minimized',
);

export const submitComposer = createAppThunk(
  (
    { redirectOnSuccess }: { redirectOnSuccess?: boolean },
    { getState, dispatch },
  ) => {
    const textareaValue = getComposerTextarea()?.value;
    if (
      textareaValue &&
      (getState().compose.get('text') as string) !== textareaValue
    ) {
      dispatch(changeCompose(textareaValue));
    }

    const { compose, meta, statuses, settings } = getState();
    const privacy = compose.get('privacy') as StatusVisibility;
    const missingAltText = (
      compose.get('media_attachments') as unknown as Immutable.List<
        Immutable.Map<string, string>
      >
    ).some(
      (media) =>
        ['image', 'gifv'].includes(media.get('type') ?? '') &&
        (media.get('description') ?? '').length === 0,
    );
    const me = meta.get('me') as string | null;
    const quotedStatusId = compose.get('quoted_status_id') as string | null;
    const quoteToPrivate =
      !!quotedStatusId &&
      privacy === 'private' &&
      statuses.getIn([quotedStatusId, 'account']) !== me &&
      !settings.getIn(['dismissed_banners', PRIVATE_QUOTE_MODAL_ID]);

    if (
      !!meta.get('missing_alt_text_modal') &&
      missingAltText &&
      privacy !== 'direct'
    ) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_MISSING_ALT_TEXT',
          modalProps: {},
        }),
      );
    } else if (quoteToPrivate) {
      dispatch(
        openModal({
          modalType: 'CONFIRM_PRIVATE_QUOTE_NOTIFY',
          modalProps: {},
        }),
      );
    } else {
      dispatch(
        submitCompose((status: ApiStatusJSON) => {
          if (redirectOnSuccess) {
            window.location.assign(status.url);
          }
        }),
      );
    }
  },
);
