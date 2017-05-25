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

const getCsrfToken = () => document.querySelector('[name="csrf-token"]').getAttribute('content');
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

const sendSubscriptionToBackend = (subscription) => {
  return fetch('/api/web/settings', {
    method: 'PUT',
    credentials: 'same-origin',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      data: {
        web_push_subscription: subscription,
      },
    }),
  });
};

getRegistration()
  .then(getPushSubscription)
  .then(({ registration, subscription }) => {;
    if (subscription !== null) {
      const currentServerKey = (new Uint8Array(subscription.options.applicationServerKey)).toString();
      const subscriptionServerKey = urlBase64ToUint8Array(getApplicationServerKey()).toString();

      if (subscriptionServerKey === currentServerKey) {
        return subscription;
      } else {
        return unsubscribe({ registration, subscription }).then(subscribe).then(sendSubscriptionToBackend);
      }
    }

    return subscribe(registration).then(sendSubscriptionToBackend);
  })
  .then(() => console.log('Ready to receive push notifications'))
  .catch(error => console.error('You will not receive push notifications', error));
