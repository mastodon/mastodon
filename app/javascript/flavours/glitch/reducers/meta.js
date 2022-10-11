import { STORE_HYDRATE } from 'flavours/glitch/actions/store';
import { APP_LAYOUT_CHANGE } from 'flavours/glitch/actions/app';
import { Map as ImmutableMap } from 'immutable';
import { layoutFromWindow } from 'flavours/glitch/is_mobile';

const initialState = ImmutableMap({
  streaming_api_base_url: null,
  access_token: null,
  layout: layoutFromWindow(),
  permissions: '0',
});

export default function meta(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return state.merge(
      action.state.get('meta'))
        .set('permissions', action.state.getIn(['role', 'permissions']))
        .set('layout', layoutFromWindow(action.state.getIn(['local_settings', 'layout']))
      );
  case APP_LAYOUT_CHANGE:
    return state.set('layout', action.layout);
  default:
    return state;
  }
};
