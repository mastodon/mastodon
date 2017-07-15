import TimelineContainer from '../mastodon/containers/timeline_container';
import React from 'react';
import ReactDOM from 'react-dom';
import loadPolyfills from '../mastodon/load_polyfills';
import ready from '../mastodon/ready';

require.context('../images/', true);

function loaded() {
  const mountNode = document.getElementById('mastodon-timeline');

  if (mountNode !== null) {
    const props = JSON.parse(mountNode.getAttribute('data-props'));
    ReactDOM.render(<TimelineContainer {...props} />, mountNode);
  }
}

function main() {
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
