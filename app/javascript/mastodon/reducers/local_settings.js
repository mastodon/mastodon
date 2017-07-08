import { LOCAL_SETTING_CHANGE } from '../actions/local_settings';
import { STORE_HYDRATE } from '../actions/store';
import Immutable from 'immutable';

const initialState = Immutable.fromJS({
  layout    : 'auto',
  stretch   : true,
  collapsed : {
    enabled     : true,
    auto        : {
      all              : false,
      notifications    : true,
      lengthy          : true,
      replies          : false,
      media            : false,
    },
    backgrounds : {
      user_backgrounds : false,
      preview_images   : false,
    },
  },
  media     : {
    letterbox   : true,
    fullwidth   : true,
  },
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
