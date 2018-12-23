import { saveSettings } from './settings';

export const EMOJI_USE = 'EMOJI_USE';

export function useEmoji(emoji) {
  return dispatch => {
    dispatch({
      type: EMOJI_USE,
      emoji,
    });

    dispatch(saveSettings());
  };
};
