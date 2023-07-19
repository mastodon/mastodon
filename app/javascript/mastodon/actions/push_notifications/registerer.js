import api from '../../api';
import { me } from '../../initial_state';
import { pushNotificationsSetting } from '../../settings';
import { decode as decodeBase64 } from '../../utils/base64';

import { setBrowserSupport, setSubscription, clearSubscription } from './setter';

// Taken from https://www.npmjs.com/package/web-push
const urlBase64ToUint8Array = (base64String) => {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding)
    .replace(/-/g, '+')
    .replace(/_/g, '/');

  return decodeBase64(base64);
};

const getApplicationServerKey = () => document.querySelector('[name="applicationServerKey"]').getAttribute('content');

const getRegistration = () => navigator.serviceWorker.ready;

const getPushSubscription = (registration) =>
  registration.pushManager.getSubscription()
    .then(subscription => ({ registration, subscription }));

const subscribe = (registration) =>
  registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(getApplicationServerKey()),
  });

const unsubscribe = ({ registration, subscription }) =>
  subscription ? subscription.unsubscribe().then(() => registration) : registration;

const sendSubscriptionToBackend = (subscription) => {
  const params = { subscription };

  if (me) {
    const data = pushNotificationsSetting.get(me);
    if (data) {
      params.data = data;
    }
  }

  return api().post('/api/web/push_subscriptions', params).then(response => response.data);
};

// Last one checks for payload support: https://web-push-book.gauntface.com/chapter-06/01-non-standards-browsers/#no-payload
const supportsPushNotifications = ('serviceWorker' in navigator && 'PushManager' in window && 'getKey' in PushSubscription.prototype);

export function register () {
  return (dispatch, getState) => {
    dispatch(setBrowserSupport(supportsPushNotifications));

    if (supportsPushNotifications) {
      if (!getApplicationServerKey()) {
        console.error('The VAPID public key is not set. You will not be able to receive Web Push Notifications.');
        return;
      }

      getRegistration()
        .then(getPushSubscription)
        .then(({ registration, subscription }) => {
          if (subscription !== null) {
            // We have a subscription, check if it is still valid
            const currentServerKey = (new Uint8Array(subscription.options.applicationServerKey)).toString();
            const subscriptionServerKey = urlBase64ToUint8Array(getApplicationServerKey()).toString();
            const serverEndpoint = getState().getIn(['push_notifications', 'subscription', 'endpoint']);

            // If the VAPID public key did not change and the endpoint corresponds
            // to the endpoint saved in the backend, the subscription is valid
            if (subscriptionServerKey === currentServerKey && subscription.endpoint === serverEndpoint) {
              return subscription;
            } else {
              // Something went wrong, try to subscribe again
              return unsubscribe({ registration, subscription }).then(subscribe).then(
                subscription => sendSubscriptionToBackend(subscription));
            }
          }

          // No subscription, try to subscribe
          return subscribe(registration).then(
            subscription => sendSubscriptionToBackend(subscription));
        })
        .then(subscription => {
          // If we got a PushSubscription (and not a subscription object from the backend)
          // it means that the backend subscription is valid (and was set during hydration)
          if (!(subscription instanceof PushSubscription)) {
            dispatch(setSubscription(subscription));
            if (me) {
              pushNotificationsSetting.set(me, { alerts: subscription.alerts });
            }
          }
        })
        .catch(error => {
          if (error.code === 20 && error.name === 'AbortError') {
            console.warn('Your browser supports Web Push Notifications, but does not seem to implement the VAPID protocol.');
          } else if (error.code === 5 && error.name === 'InvalidCharacterError') {
            console.error('The VAPID public key seems to be invalid:', getApplicationServerKey());
          }

          // Clear alerts and hide UI settings
          dispatch(clearSubscription());
          if (me) {
            pushNotificationsSetting.remove(me);
          }

          return getRegistration()
            .then(getPushSubscription)
            .then(unsubscribe);
        })
        .catch(console.warn);
    } else {
      console.warn('Your browser does not support Web Push Notifications.');
    }
  };
}

export function saveSettings() {
  return (_, getState) => {
    const state = getState().get('push_notifications');
    const subscription = state.get('subscription');
    const alerts = state.get('alerts');
    const data = { alerts };

    api().put(`/api/web/push_subscriptions/${subscription.get('id')}`, {
      data,
    }).then(() => {
      if (me) {
        pushNotificationsSetting.set(me, data);
      }
    }).catch(console.warn);
  };
}
