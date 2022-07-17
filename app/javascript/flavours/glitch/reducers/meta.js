import { STORE_HYDRATE } from 'flavours/glitch/actions/store';
import { Map as ImmutableMap } from 'immutable';

const initialState = ImmutableMap({
  streaming_api_base_url: null,
  access_token: null,
  permissions: '0',
});

export default function meta(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return state.merge(action.state.get('meta')).set('permissions', action.state.getIn(['role', 'permissions']));
  default:
    return state;
  }
};
