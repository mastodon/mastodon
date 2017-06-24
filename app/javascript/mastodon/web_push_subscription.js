import axios from 'axios';
import { store } from './containers/mastodon';
import { setBrowserSupport, setSubscription, clearSubscription, saveSettings } from './actions/push_notifications';

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
  subscription.unsubscribe().then(() => registration);

const sendSubscriptionToBackend = (subscription) =>
  axios.post('/api/web/push_subscriptions', {
    data: subscription,
  }).then(response => response.data);

const supportsPushNotifications = ('serviceWorker' in navigator && 'PushManager' in window);

store.dispatch(setBrowserSupport(supportsPushNotifications));

export function register () {
  if (supportsPushNotifications) {
    getRegistration()
      .then(getPushSubscription)
      .then(({ registration, subscription }) => {
        if (subscription !== null) {
          const currentServerKey = (new Uint8Array(subscription.options.applicationServerKey)).toString();
          const subscriptionServerKey = urlBase64ToUint8Array(getApplicationServerKey()).toString();
          const serverEndpoint = store.getState().getIn(['push_notifications', 'subscription', 'endpoint']);

          if (subscriptionServerKey === currentServerKey && subscription.endpoint === serverEndpoint) {
            return subscription;
          } else {
            return unsubscribe({ registration, subscription }).then(subscribe).then(sendSubscriptionToBackend);
          }
        }

        return subscribe(registration).then(sendSubscriptionToBackend);
      })
      .then(subscription => {
        if (!(subscription instanceof PushSubscription)) {
          store.dispatch(setSubscription(subscription));
        }
      })
      .catch(error => {
        console.error(error);

        store.dispatch(clearSubscription());
        store.dispatch(saveSettings());

        try {
          getRegistration()
            .then(getPushSubscription)
            .then(unsubscribe);
        } catch (e) {
          console.error(error);
        }
      });
  }
}

