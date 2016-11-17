//= require_self
//= require react_ujs

window.React    = require('react');
window.ReactDOM = require('react-dom');
window.Perf     = require('react-addons-perf');

if (!window.Intl) {
  require('intl');
  require('intl/locale-data/jsonp/en.js');
}

//= require_tree ./components

window.Mastodon = require('./components/containers/mastodon');
