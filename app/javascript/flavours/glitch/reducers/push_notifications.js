import { STORE_HYDRATE } from 'flavours/glitch/actions/store';
import { SET_BROWSER_SUPPORT, SET_SUBSCRIPTION, CLEAR_SUBSCRIPTION, SET_ALERTS } from 'flavours/glitch/actions/push_notifications';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  subscription: null,
  alerts: new Immutable.Map({
    follow: false,
    follow_request: false,
    favourite: false,
    reblog: false,
    mention: false,
    poll: false,
  }),
  isSubscribed: false,
  browserSupport: false,
});

export default function push_subscriptions(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE: {
    const push_subscription = action.state.get('push_subscription');

    if (push_subscription) {
      return state
        .set('subscription', new Immutable.Map({
          id: push_subscription.get('id'),
          endpoint: push_subscription.get('endpoint'),
        }))
        .set('alerts', push_subscription.get('alerts') || initialState.get('alerts'))
        .set('isSubscribed', true);
    }

    return state;
  }
  case SET_SUBSCRIPTION:
    return state
      .set('subscription', new Immutable.Map({
        id: action.subscription.id,
        endpoint: action.subscription.endpoint,
      }))
      .set('alerts', new Immutable.Map(action.subscription.alerts))
      .set('isSubscribed', true);
  case SET_BROWSER_SUPPORT:
    return state.set('browserSupport', action.value);
  case CLEAR_SUBSCRIPTION:
    return initialState;
  case SET_ALERTS:
    return state.setIn(action.path, action.value);
  default:
    return state;
  }
}
