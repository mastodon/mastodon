export const EMOJI_USE = 'EMOJI_USE';

export function useEmoji(emoji) {
  return {
    type: EMOJI_USE,
    emoji,
  };
};
