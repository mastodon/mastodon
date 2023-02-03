import { STORE_HYDRATE } from 'flavours/glitch/actions/store';
import { Map as ImmutableMap } from 'immutable';

const initialState = ImmutableMap({
  accept_content_types: [],
});

export default function meta(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return state.merge(action.state.get('media_attachments'));
  default:
    return state;
  }
}
