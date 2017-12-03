import axios from 'axios';
import { store } from './containers/mastodon';
import { setBrowserSupport, setSubscription, clearSubscription } from './actions/push_notifications';

// Taken from https://www.npmjs.com/package/web-push
const urlBase64ToUint8Array = (base64String) => {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding)
    .replace(/\-/g, '+')
    .replace(/_/g, '/');

  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
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

  const me = store.getState().getIn(['meta', 'me']);
  if (me) {
    const data = getSettingsFromLocalStorage(me);
    if (data) {
      params.data = data;
    }
  }

  return axios.post('/api/web/push_subscriptions', params).then(response => response.data);
};

// Last one checks for payload support: https://web-push-book.gauntface.com/chapter-06/01-non-standards-browsers/#no-payload
const supportsPushNotifications = ('serviceWorker' in navigator && 'PushManager' in window && 'getKey' in PushSubscription.prototype);

const SUBSCRIPTION_DATA_STORAGE_KEY = 'mastodon_push_notification_data';

export function register () {
  store.dispatch(setBrowserSupport(supportsPushNotifications));
  const me = store.getState().getIn(['meta', 'me']);

  if (me && !getSettingsFromLocalStorage(me)) {
    const alerts = store.getState().getIn(['push_notifications', 'alerts']);
    if (alerts) {
      setSettingsToLocalStorage(me, { alerts: alerts });
    }
  }

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
          const serverEndpoint = store.getState().getIn(['push_notifications', 'subscription', 'endpoint']);

          // If the VAPID public key did not change and the endpoint corresponds
          // to the endpoint saved in the backend, the subscription is valid
          if (subscriptionServerKey === currentServerKey && subscription.endpoint === serverEndpoint) {
            return subscription;
          } else {
            // Something went wrong, try to subscribe again
            return unsubscribe({ registration, subscription }).then(subscribe).then(sendSubscriptionToBackend);
          }
        }

        // No subscription, try to subscribe
        return subscribe(registration).then(sendSubscriptionToBackend);
      })
      .then(subscription => {
        // If we got a PushSubscription (and not a subscription object from the backend)
        // it means that the backend subscription is valid (and was set during hydration)
        if (!(subscription instanceof PushSubscription)) {
          store.dispatch(setSubscription(subscription));
          if (me) {
            setSettingsToLocalStorage(me, { alerts: subscription.alerts });
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
        store.dispatch(clearSubscription());
        if (me) {
          removeSettingsFromLocalStorage(me);
        }

        try {
          getRegistration()
            .then(getPushSubscription)
            .then(unsubscribe);
        } catch (e) {

        }
      });
  } else {
    console.warn('Your browser does not support Web Push Notifications.');
  }
}

export function setSettingsToLocalStorage(id, data) {
  try {
    localStorage.setItem(`${SUBSCRIPTION_DATA_STORAGE_KEY}_${id}`, JSON.stringify(data));
  } catch (e) {}
}

export function getSettingsFromLocalStorage(id) {
  try {
    return JSON.parse(localStorage.getItem(`${SUBSCRIPTION_DATA_STORAGE_KEY}_${id}`));
  } catch (e) {}

  return null;
}

export function removeSettingsFromLocalStorage(id) {
  localStorage.removeItem(`${SUBSCRIPTION_DATA_STORAGE_KEY}_${id}`);
}
