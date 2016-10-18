import { configure } from '@kadira/storybook';
import React from 'react';
import { storiesOf, action } from '@kadira/storybook';

import './storybook.css'

window.storiesOf = storiesOf;
window.action    = action;
window.React     = React;

function loadStories () {
  require('./stories/loading_indicator.story.jsx');
  require('./stories/button.story.jsx');
  require('./stories/tabs_bar.story.jsx');
}

configure(loadStories, module);
