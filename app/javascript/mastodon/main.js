import { createRoot } from 'react-dom/client';
import * as registerPushNotifications from 'mastodon/actions/push_notifications';
import { setupBrowserNotifications } from 'mastodon/actions/notifications';
import { default as Mastodon, store } from 'mastodon/containers/mastodon';
import ready from 'mastodon/ready';

const perf = require('mastodon/performance');

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
    const root      = createRoot(mountNode);
    const props     = JSON.parse(mountNode.getAttribute('data-props'));

    root.render(<Mastodon {...props} />);
    store.dispatch(setupBrowserNotifications());
    if (process.env.NODE_ENV === 'production') {
      // avoid offline in dev mode because it's harder to debug
      require('offline-plugin/runtime').install();
      store.dispatch(registerPushNotifications.register());
    }
    perf.stop('main()');
  });
}

export default main;
