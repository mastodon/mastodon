import { FAVOURITE_TAGS_SUCCESS, TOGGLE_FAVOURITE_TAGS } from '../actions/favourite_tags';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  tags: Immutable.List(),
  visible: true,
});

export default function favourite_tags(state = initialState, action) {
  switch(action.type) {
  case FAVOURITE_TAGS_SUCCESS:
    return state.set('tags', Immutable.fromJS(action.tags));
  case TOGGLE_FAVOURITE_TAGS:
    return state.set('visible', !state.get('visible'));
  default:
    return state;
  }
}
