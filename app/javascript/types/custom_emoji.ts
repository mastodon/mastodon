import type { Record } from 'immutable';

export interface CustomEmojiRawValues {
  shortcode: string;
  static_url: string;
  url: string;
}
export type CustomEmoji = Record<CustomEmojiRawValues>;
