import loadPolyfills from '../mastodon/load_polyfills';
import { start } from '../mastodon/common';

start();

function loaded() {
  const React             = require('react');
  const ReactDOM          = require('react-dom');

  const TimelineContainer = require('../mastodon/containers/timeline_container').default;
  const timelineMountNode = document.getElementById('mastodon-timeline');
  if (timelineMountNode !== null) {
    const props = JSON.parse(timelineMountNode.getAttribute('data-props'));
    ReactDOM.render(<TimelineContainer {...props} />, timelineMountNode);
  }

  const LanguageSelectContainer = require('../mastodon/containers/language_select_container').default;
  const selectorMountNode = document.getElementById('language-selector');
  if (selectorMountNode !== null) {
    const props = JSON.parse(selectorMountNode.getAttribute('data-props'));
    ReactDOM.render(<LanguageSelectContainer {...props} />, selectorMountNode);
  }
}

function main() {
  const ready = require('../mastodon/ready').default;
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
