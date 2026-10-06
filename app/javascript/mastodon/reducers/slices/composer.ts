import { createSlice, isAction } from '@reduxjs/toolkit';
import type { PayloadAction } from '@reduxjs/toolkit';

import { length } from 'stringz';

import {
  changeCompose,
  clearComposeSuggestions,
  COMPOSE_DIRECT,
  COMPOSE_FOCUS,
  COMPOSE_MENTION,
  COMPOSE_REPLY,
  COMPOSE_SET_STATUS,
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
import { REDRAFT } from '@/mastodon/actions/statuses';
import type {
  ApiStatusJSON,
  StatusVisibility,
} from '@/mastodon/api_types/statuses';
import { countableText } from '@/mastodon/features/compose/util/counter';
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
export interface ComposerTextareaSelection {
  start: number;
  end: number;
}

interface PendingFocus {
  selection: ComposerTextareaSelection | null;
}

type DisplayState = 'hidden' | 'showing' | 'minimized';

export type ComposeType = 'post' | 'message' | 'reply' | 'replyPrivate';

export type ComposerPublishError = 'empty' | 'too-long';

interface ComposerState {
  displayState: DisplayState;
  pendingFocus: PendingFocus | null;
  publishErrors: ComposerPublishError[];
}

const initialState: ComposerState = {
  displayState: 'hidden',
  pendingFocus: null,
  publishErrors: [],
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
    requestFocus(
      state,
      action: PayloadAction<ComposerTextareaSelection | undefined>,
    ) {
      state.pendingFocus = { selection: action.payload ?? null };
    },
    clearPendingFocus(state) {
      state.pendingFocus = null;
    },
    addError(state, action: PayloadAction<ComposerPublishError>) {
      if (!state.publishErrors.includes(action.payload)) {
        state.publishErrors.push(action.payload);
      }
    },
    clearErrors(state) {
      state.publishErrors = [];
    },
  },
  extraReducers(builder) {
    builder.addMatcher(
      (action) =>
        isAction(action) &&
        [
          COMPOSE_REPLY,
          COMPOSE_FOCUS,
          COMPOSE_MENTION,
          COMPOSE_DIRECT,
          COMPOSE_SET_STATUS,
          REDRAFT,
        ].includes(action.type),
      (state) => {
        state.displayState = 'showing';
      },
    );
  },
});

export const composer = composerSlice.reducer;

export const {
  requestFocus: requestComposerFocus,
  clearPendingFocus: clearComposerFocusRequest,
  clearErrors: clearComposerErrors,
} = composerSlice.actions;

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
  (payload: ComposeNewPayload | undefined = {}, { dispatch, getState }) => {
    // Always show the composer if it is closed or minimized.
    dispatch(composerSlice.actions.showComposer());

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
    dispatch(composerSlice.actions.clearErrors());
    if (payload.type === 'message') {
      const account =
        !!payload.toAccountId && getState().accounts.get(payload.toAccountId);
      if (account) {
        dispatch(directCompose(account));
      } else {
        dispatch(changeComposeVisibility('direct'));
        dispatch(requestComposerFocus());
      }
    } else if (payload.type === 'reply') {
      dispatch(replyComposeById(payload.toStatusId));
    } else {
      dispatch(requestComposerFocus());
    }
  },
);

export const resetComposer = createAppThunk((_arg, { dispatch }) => {
  dispatch(composerSlice.actions.hideComposer());
  dispatch(composerSlice.actions.clearErrors());
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

    const { compose, meta, statuses, server, settings } = getState();

    if (!selectComposerIsChanged(getState())) {
      dispatch(composerSlice.actions.addError('empty'));
      return;
    }

    const maxChars =
      server.server.item?.configuration.statuses.max_characters ?? 500;
    let text = compose.get('text') as string;
    const spoilerText = compose.get('spoiler_text');
    if (compose.get('spoiler') && typeof spoilerText === 'string') {
      text += spoilerText;
    }
    const textLength = length(countableText(text));
    if (textLength > maxChars) {
      dispatch(composerSlice.actions.addError('too-long'));
      return;
    }

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
    } else if (!!compose.get('spoiler') && !compose.get('spoiler_text')) {
      dispatch(
        openModal({
          modalType: 'COMPOSER_ADD_CONTENT_WARNING',
          modalProps: {
            redirectOnSuccess,
          },
        }),
      );
    } else {
      dispatch(
        submitCompose((status: ApiStatusJSON) => {
          if (redirectOnSuccess) {
            window.location.assign(status.url);
          }

          dispatch(resetComposer());
        }),
      );
    }
  },
);
