import { MEDIA_OPEN, MODAL_CLOSE } from '../actions/modal';
import Immutable                   from 'immutable';

const initialState = Immutable.Map({
  url: '',
  open: false
});

export default function modal(state = initialState, action) {
  switch(action.type) {
  case MEDIA_OPEN:
    return state.withMutations(map => {
      map.set('url', action.url);
      map.set('open', true);
    });
  case MODAL_CLOSE:
    return state.set('open', false);
  default:
    return state;
  }
};
