//  Package imports.
import { Map as ImmutableMap } from 'immutable';

//  Our imports.
import { STORE_HYDRATE } from 'flavours/glitch/actions/store';
import { LOCAL_SETTING_CHANGE } from 'flavours/glitch/actions/local_settings';

const initialState = ImmutableMap({
  layout    : 'auto',
  stretch   : true,
  navbar_under : false,
  side_arm  : 'none',
  collapsed : ImmutableMap({
    enabled     : true,
    auto        : ImmutableMap({
      all              : false,
      notifications    : true,
      lengthy          : true,
      reblogs          : false,
      replies          : false,
      media            : false,
    }),
    backgrounds : ImmutableMap({
      user_backgrounds : false,
      preview_images   : false,
    }),
  }),
  media     : ImmutableMap({
    letterbox   : true,
    fullwidth   : true,
  }),
});

const hydrate = (state, localSettings) => state.mergeDeep(localSettings);

export default function localSettings(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return hydrate(state, action.state.get('local_settings'));
  case LOCAL_SETTING_CHANGE:
    return state.setIn(action.key, action.value);
  default:
    return state;
  }
};
