import { createSlice } from '@reduxjs/toolkit';

import {
  directCompose,
  replyComposeById,
  resetCompose,
} from '@/mastodon/actions/compose';
import { changeComposeVisibility } from '@/mastodon/actions/compose_typed';
import { openModal } from '@/mastodon/actions/modal';
import {
  createAppSelector,
  createAppThunk,
} from '@/mastodon/store/typed_functions';

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
export const { minimizeComposerToggle } = composerSlice.actions;

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
type ComposeNewPayload = ComposeNewPost | ComposeNewReply | ComposeNewMessage;

export const openNewComposer = createAppThunk(
  (payload: ComposeNewPayload, { dispatch, getState }) => {
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
  },
);

export const resetComposer = createAppThunk((_arg, { dispatch }) => {
  dispatch(composerSlice.actions.hideComposer());
  dispatch(resetCompose());
});

export const hideComposer = createAppThunk((_arg, { getState, dispatch }) => {
  const compose = getState().compose;
  const isChanged =
    !!compose.get('text') ||
    !!compose.get('spoiler_text') ||
    !!compose.get('poll') ||
    (compose.get('media_attachments') as unknown as Immutable.List<unknown>)
      .size > 0;

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
