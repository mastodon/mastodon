//= require_self
//= require react_ujs

window.React    = require('react');
window.ReactDOM = require('react-dom');
window.Perf     = require('react-addons-perf');

//= require_tree ./components

window.Mastodon = require('./components/containers/mastodon');
