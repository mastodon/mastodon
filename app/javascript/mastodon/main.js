// allow override variables here
require.context('../../assets/stylesheets/', false, /variables.*\.scss$/);

// import default stylesheet with variables
require('font-awesome/css/font-awesome.css');
require('../styles/application.scss');

function onDomContentLoaded(callback) {
  if (document.readyState !== 'loading') {
    callback();
  } else {
    document.addEventListener('DOMContentLoaded', callback);
  }
}

function main() {
  const Mastodon = require('mastodon/containers/mastodon').default;
  const React = require('react');
  const ReactDOM = require('react-dom');
  window.Perf = require('react-addons-perf');

  require.context('../images/', true);

  // import customization styles
  require.context('../../assets/stylesheets/', false, /custom.*\.scss$/);

  onDomContentLoaded(() => {
    const mountNode = document.getElementById('mastodon');
    const props = JSON.parse(mountNode.getAttribute('data-props'));

    ReactDOM.render(<Mastodon {...props} />, mountNode);
  });
}

export default main;
