import { List as ImmutableList, fromJS as ConvertToImmutable } from 'immutable';

import { CUSTOM_EMOJIS_FETCH_SUCCESS } from '../actions/custom_emojis';
import { buildCustomEmojis } from '../features/emoji/emoji';
import { search as emojiSearch } from '../features/emoji/emoji_mart_search_light';

const initialState = ImmutableList([]);

export default function custom_emojis(state = initialState, action) {
  if(action.type === CUSTOM_EMOJIS_FETCH_SUCCESS) {
    state = ConvertToImmutable(action.custom_emojis);
    emojiSearch('', { custom: buildCustomEmojis(state) });
  }

  return state;
}
