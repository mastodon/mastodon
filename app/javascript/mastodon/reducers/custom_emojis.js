import { List as ImmutableList } from 'immutable';
import { STORE_HYDRATE } from '../actions/store';

const initialState = ImmutableList();

export default function statuses(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return action.state.get('custom_emojis');
  default:
    return state;
  }
};
