import { Map as ImmutableMap } from 'immutable';
import { NOTIFICATIONS_UPDATE } from 'mastodon/actions/notifications';
import { APP_FOCUS, APP_UNFOCUS } from 'mastodon/actions/app';

const initialState = ImmutableMap({
  focused: true,
  unread: 0,
});

export default function missed_updates(state = initialState, action) {
  switch(action.type) {
  case APP_FOCUS:
    return state.set('focused', true).set('unread', 0);
  case APP_UNFOCUS:
    return state.set('focused', false);
  case NOTIFICATIONS_UPDATE:
    return state.get('focused') ? state : state.update('unread', x => x + 1);
  default:
    return state;
  }
}
