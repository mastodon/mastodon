import React from 'react';
import ReactDOM from 'react-dom';
import { setupBrowserNotifications } from 'mastodon/actions/notifications';
import Mastodon, { store } from 'mastodon/containers/mastodon';
import ready from 'mastodon/ready';

const perf = require('mastodon/performance');

/**
 * @returns {Promise<void>}
 */
function main() {
  perf.start('main()');

  return ready(async () => {
    const mountNode = document.getElementById('mastodon');
    const props = JSON.parse(mountNode.getAttribute('data-props'));

    ReactDOM.render(<Mastodon {...props} />, mountNode);
    store.dispatch(setupBrowserNotifications());

    if (process.env.NODE_ENV === 'production' && 'serviceWorker' in navigator) {
      const [{ Workbox }, { me }] = await Promise.all([
        import('workbox-window'),
        import('mastodon/initial_state'),
      ]);

      const wb = new Workbox('/sw.js');

      try {
        await wb.register();
      } catch (err) {
        console.error(err);

        return;
      }

      if (me) {
        const registerPushNotifications = await import('mastodon/actions/push_notifications');

        store.dispatch(registerPushNotifications.register());
      }
    }

    perf.stop('main()');
  });
}

export default main;
