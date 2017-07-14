import ready from './ready';

const perf = require('./performance');

function main() {
  perf.start('main()');
  const Mastodon = require('mastodon/containers/mastodon').default;
  const React = require('react');
  const ReactDOM = require('react-dom');

  require.context('../images/', true);

  if (window.history && history.replaceState) {
    const { pathname, search, hash } = window.location;
    const path = pathname + search + hash;
    if (!(/^\/web[$/]/).test(path)) {
      history.replaceState(null, document.title, `/web${path}`);
    }
  }

  ready(() => {
    const mountNode = document.getElementById('mastodon');
    const props = JSON.parse(mountNode.getAttribute('data-props'));

    ReactDOM.render(<Mastodon {...props} />, mountNode);
    if (process.env.NODE_ENV === 'production') {
      // avoid offline in dev mode because it's harder to debug
      const OfflinePluginRuntime = require('offline-plugin/runtime');
      const WebPushSubscription = require('./web_push_subscription');

      OfflinePluginRuntime.install();
      WebPushSubscription.register();
    }
    perf.stop('main()');
  });
}

export default main;
