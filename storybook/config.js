import { configure } from '@kadira/storybook';
import React from 'react';
import { storiesOf, action } from '@kadira/storybook';

window.storiesOf = storiesOf;
window.action = action;
window.React = React;

function loadStories () {
  require('./stories/loading_indicator.story.jsx');
  // You can require as many stories as you need.
}

configure(loadStories, module);
