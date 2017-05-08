import Mastodon from 'mastodon/containers/mastodon';
import React from 'react';
import ReactDOM from 'react-dom';
import Rails from 'rails-ujs';
import 'font-awesome/css/font-awesome.css';
import '../styles/application.scss';

if (!window.Intl) {
  require('intl');
  require('intl/locale-data/jsonp/en.js');
}

window.Perf = require('react-addons-perf');

Rails.start();

require.context('../images/', true);
require.context('../../assets/stylesheets/', false, /custom.*\.scss$/);

document.addEventListener('DOMContentLoaded', () => {
  const mountNode = document.getElementById('mastodon');
  const props = JSON.parse(mountNode.getAttribute('data-props'));

  ReactDOM.render(<Mastodon {...props} />, mountNode);
});
