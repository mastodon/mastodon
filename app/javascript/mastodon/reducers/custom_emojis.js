import { List as ImmutableList } from 'immutable';
import { STORE_HYDRATE } from '../actions/store';
import { emojiIndex } from 'emoji-mart';
import { buildCustomEmojis } from '../emoji';

const initialState = ImmutableList();

export default function custom_emojis(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    emojiIndex.search('', { custom: buildCustomEmojis(action.state.get('custom_emojis', [])) });
    return action.state.get('custom_emojis');
  default:
    return state;
  }
};
