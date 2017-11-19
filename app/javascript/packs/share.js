import loadPolyfills from 'themes/glitch/util/load_polyfills';

require.context('../images/', true);

function loaded() {
  const ComposeContainer = require('themes/glitch/containers/compose_container').default;
  const React = require('react');
  const ReactDOM = require('react-dom');
  const mountNode = document.getElementById('mastodon-compose');

  if (mountNode !== null) {
    const props = JSON.parse(mountNode.getAttribute('data-props'));
    ReactDOM.render(<ComposeContainer {...props} />, mountNode);
  }
}

function main() {
  const ready = require('themes/glitch/util/ready').default;
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
