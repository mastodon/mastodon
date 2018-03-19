import { TREND_TAGS_SUCCESS, TOGGLE_TREND_TAGS } from '../actions/trend_tags';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  tags: Immutable.Map({
    updated_at: '',
    score: Immutable.Map(),
  }),
  visible: true,
});

export default function trend_tags(state = initialState, action) {
  switch(action.type) {
  case TREND_TAGS_SUCCESS:
    return state.set('tags', Immutable.fromJS(action.tags));
  case TOGGLE_TREND_TAGS:
    return state.set('visible', !state.get('visible'));
  default:
    return state;
  }
}
