import './public-path';

import loadPolyfills from 'mastodon/load_polyfills';
import { start } from 'mastodon/common';

start();

function loaded() {
  const { createRoot }                 = require('react-dom/client');
  const { default: TimelineContainer } = require('mastodon/containers/timeline_container');

  const mountNode = document.getElementById('mastodon-timeline');

  if (mountNode !== null) {
    const root  = createRoot(mountNode);
    const props = JSON.parse(mountNode.getAttribute('data-props'));

    root.render(<TimelineContainer {...props} />);
  }
}

function main() {
  const { default: ready } = require('mastodon/ready');
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
