// @ts-check

import { createRoot } from 'react-dom/client';

import { setupBrowserNotifications } from 'mastodon/actions/notifications';
import Mastodon from 'mastodon/containers/mastodon';
import { me } from 'mastodon/initial_state';
import * as perf from 'mastodon/performance';
import ready from 'mastodon/ready';
import { store } from 'mastodon/store';
import { isProduction } from 'mastodon/utils/environment';

/**
 * @param {string} scriptURL
 * @returns {Promise<ServiceWorkerRegistration>}
 */
async function registerServiceWorker(scriptURL) {
  const registration = await navigator.serviceWorker.register(scriptURL);

  if ('Notification' in window && Notification.permission === 'granted') {
    const registerPushNotifications = await import('mastodon/actions/push_notifications');

    store.dispatch(registerPushNotifications.register());
  }

  return registration;
}

/**
 * @returns {Promise<void>}
 */
function main() {
  perf.start('main()');

  return ready(async () => {
    const mountNode = document.getElementById('mastodon');

    if (mountNode) {
      const rawProps = mountNode.getAttribute('data-props');
      const props = rawProps ? JSON.parse(rawProps) : {};

      const root = createRoot(mountNode);
      root.render(<Mastodon {...props} />);
    }

    store.dispatch(setupBrowserNotifications());

    if (isProduction() && me && 'serviceWorker' in navigator) {
      try {
        await registerServiceWorker('/sw.js');
      } catch (err) {
        console.error(err);
      }
    }

    perf.stop('main()');
  });
}

export default main;
