import type { RecordOf } from 'immutable';
import { Record } from 'immutable';

import type { ApiCustomEmojiJSON } from 'flavours/glitch/api_types/custom_emoji';

type CustomEmojiShape = Required<ApiCustomEmojiJSON>; // no changes from server shape
export type CustomEmoji = RecordOf<CustomEmojiShape>;

export const CustomEmojiFactory = Record<CustomEmojiShape>({
  shortcode: '',
  static_url: '',
  url: '',
  category: '',
  visible_in_picker: false,
});
