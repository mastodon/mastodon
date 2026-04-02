import type { RecordOf, List as ImmutableList } from 'immutable';
import { Record as ImmutableRecord, isList } from 'immutable';

import type { ApiCustomEmojiJSON } from 'mastodon/api_types/custom_emoji';

type CustomEmojiShape = Required<ApiCustomEmojiJSON>; // no changes from server shape
export type CustomEmoji = RecordOf<CustomEmojiShape>;

export const CustomEmojiFactory = ImmutableRecord<CustomEmojiShape>({
  shortcode: '',
  static_url: '',
  url: '',
  category: '',
  featured: false,
  visible_in_picker: false,
});

export type EmojiMap = Record<string, ApiCustomEmojiJSON>;

export function makeEmojiMap(
  emojis: ApiCustomEmojiJSON[] | ImmutableList<CustomEmoji>,
) {
  if (isList(emojis)) {
    return emojis.reduce<EmojiMap>((obj, emoji) => {
      obj[`:${emoji.shortcode}:`] = emoji.toJS();
      return obj;
    }, {});
  } else
    return emojis.reduce<EmojiMap>((obj, emoji) => {
      obj[`:${emoji.shortcode}:`] = emoji;
      return obj;
    }, {});
}
