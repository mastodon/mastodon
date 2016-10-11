import { configure } from '@kadira/storybook';
import React from 'react';
import { storiesOf, action } from '@kadira/storybook';

import './storybook.css'
// for now just simply $ rake asset:precompile && mv public/assets/application-ebf... storybook/application.css
import './application.css'

window.storiesOf = storiesOf;
window.action = action;
window.React = React;

function loadStories () {
  require('./stories/loading_indicator.story.jsx');
  require('./stories/button.story.jsx');
}

configure(loadStories, module);
