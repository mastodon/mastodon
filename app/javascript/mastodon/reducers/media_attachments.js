import { STORE_HYDRATE_LAZY } from '../actions/store';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  accept_content_types: [],
});

export default function meta(state = initialState, action) {
  switch(action.type) {
  case `${STORE_HYDRATE_LAZY}-media_attachments`:
    return state.merge(action.state.get('media_attachments'));
  default:
    return state;
  }
};
