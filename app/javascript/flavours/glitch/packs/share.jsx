import 'packs/public-path';
import { loadPolyfills } from 'flavours/glitch/polyfills';
import ComposeContainer from 'flavours/glitch/containers/compose_container';
import React from 'react';
import ReactDOM from 'react-dom';
import ready from 'flavours/glitch/ready';

function loaded() {
  const mountNode = document.getElementById('mastodon-compose');

  if (mountNode) {
    const attr = mountNode.getAttribute('data-props');
    if(!attr) return;

    const props = JSON.parse(attr);
    ReactDOM.render(<ComposeContainer {...props} />, mountNode);
  }
}

function main() {
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
