import { SETTING_CHANGE } from '../actions/settings';
import { STORE_HYDRATE } from '../actions/store';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  notifications: Immutable.Map({
    alerts: Immutable.Map({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true
    }),

    shows: Immutable.Map({
      follow: true,
      favourite: true,
      reblog: true,
      mention: true
    })
  })
});

export default function settings(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return state.merge(action.state.get('settings'));
  case SETTING_CHANGE:
    return state.setIn(action.key, action.value);
  default:
    return state;
  }
};
