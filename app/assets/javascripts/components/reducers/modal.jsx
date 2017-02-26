import {
  MEDIA_OPEN,
  MODAL_CLOSE,
  MODAL_INDEX_DECREASE,
  MODAL_INDEX_INCREASE
} from '../actions/modal';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  media: null,
  index: 0,
  open: false
});

export default function modal(state = initialState, action) {
  switch(action.type) {
  case MEDIA_OPEN:
    return state.withMutations(map => {
      map.set('media', action.media);
      map.set('index', action.index);
      map.set('open', true);
    });
  case MODAL_CLOSE:
    return state.set('open', false);
  case MODAL_INDEX_DECREASE:
    return state.update('index', index => (index - 1) % state.get('media').size);
  case MODAL_INDEX_INCREASE:
    return state.update('index', index => (index + 1) % state.get('media').size);
  default:
    return state;
  }
};
