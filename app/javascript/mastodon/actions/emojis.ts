import type { EmojiData } from 'emoji-mart';

import { createAppThunk } from '../store/typed_functions';

import { saveSettings } from './settings';

export const EMOJI_USE = 'EMOJI_USE';

export const emojiUse = createAppThunk((emoji: EmojiData, { dispatch }) => {
  dispatch({
    type: EMOJI_USE,
    emoji,
  });
  dispatch(saveSettings());
});
