import { Map } from 'immutable';
import type { Action } from 'redux';
import { NOTIFICATIONS_UPDATE } from '../actions/notifications';
import type { MastodonMap } from '../../types/util';
import { focusApp, unfocusApp } from '../actions/app';

type MissedUpdatesState = MastodonMap<{
  focused: boolean;
  unread: number;
}>;
const initialState: MissedUpdatesState = Map({
  focused: true,
  unread: 0,
});

export default function missed_updates(
  state = initialState,
  action: Action<string>,
) {
  switch (action.type) {
  case focusApp.type:
    return state.set('focused', true).set('unread', 0);
  case unfocusApp.type:
    return state.set('focused', false);
  case NOTIFICATIONS_UPDATE:
    return state.get('focused')
      ? state
      : state.update('unread', (x) => x + 1);
  default:
    return state;
  }
}
