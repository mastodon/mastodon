import { FAVOURITE_TAGS_SUCCESS } from '../actions/favourite_tags';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  tags: Immutable.List(),
});

export default function favourite_tags(state = initialState, action) {
  switch(action.type) {
  case FAVOURITE_TAGS_SUCCESS:
    return state.set('tags', Immutable.fromJS(action.tags));
  default:
    return state;
  }
}
