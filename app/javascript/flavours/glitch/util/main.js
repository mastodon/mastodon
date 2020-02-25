import * as registerPushNotifications from 'flavours/glitch/actions/push_notifications';
import { default as Mastodon, store } from 'flavours/glitch/containers/mastodon';
import React from 'react';
import ReactDOM from 'react-dom';
import ready from './ready';

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
    if (process.env.NODE_ENV === 'production') {
      // avoid offline in dev mode because it's harder to debug
      require('offline-plugin/runtime').install();
      store.dispatch(registerPushNotifications.register());
    }
    perf.stop('main()');
  });
}

export default main;
