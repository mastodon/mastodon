import { List as ImmutableList } from 'immutable';
import { STORE_HYDRATE } from '../actions/store';
import { search as emojiSearch } from '../features/emoji/emoji_mart_search_light';
import { buildCustomEmojis } from '../features/emoji/emoji';

const initialState = ImmutableList();

export default function custom_emojis(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    emojiSearch('', { custom: buildCustomEmojis(action.state.get('custom_emojis', [])) });
    return action.state.get('custom_emojis');
  default:
    return state;
  }
};
