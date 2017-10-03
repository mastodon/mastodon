import { List as ImmutableList } from 'immutable';
import { STORE_HYDRATE } from '../actions/store';
import { search as emojiSearch } from '../emoji_index_light';
import { buildCustomEmojis } from '../emoji';

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
