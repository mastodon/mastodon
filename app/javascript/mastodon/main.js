import React from 'react';
import ReactDOM from 'react-dom';
import * as registerPushNotifications from 'mastodon/actions/push_notifications';
import { setupBrowserNotifications } from 'mastodon/actions/notifications';
import Mastodon, { store } from 'mastodon/containers/mastodon';
import ready from 'mastodon/ready';

const perf = require('./performance');

function main() {
  perf.start('main()');

  if (window.history && history.replaceState) {
    const { pathname, search, hash } = window.location;
    const path = pathname + search + hash;
    if (!(/^\/web($|\/)/).test(path)) {
      history.replaceState(null, document.title, `/web${path}`);
    }
  }

  ready(() => {
    const mountNode = document.getElementById('mastodon');
    const props = JSON.parse(mountNode.getAttribute('data-props'));

    ReactDOM.render(<Mastodon {...props} />, mountNode);
    store.dispatch(setupBrowserNotifications());

    if (process.env.NODE_ENV === 'production' && 'serviceWorker' in navigator) {
      import('workbox-window')
        .then(({ Workbox }) => {
          const wb = new Workbox('/sw.js');

          return wb.register();
        })
        .then(() => {
          store.dispatch(registerPushNotifications.register());
        })
        .catch(err => {
          console.error(err);
        });
    }
    perf.stop('main()');
  });
}

export default main;
