import type {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
} from './constants';

export type EmojiMode =
  | typeof EMOJI_MODE_NATIVE
  | typeof EMOJI_MODE_NATIVE_WITH_FLAGS
  | typeof EMOJI_MODE_TWEMOJI;
