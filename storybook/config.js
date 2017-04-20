import { configure, setAddon } from '@kadira/storybook';
import IntlAddon from 'react-storybook-addon-intl';
import React from 'react';
import { storiesOf, action } from '@kadira/storybook';
import { addLocaleData } from 'react-intl';
import en from 'react-intl/locale-data/en';
import '../app/assets/stylesheets/components.scss'
import './storybook.scss'

setAddon(IntlAddon);
addLocaleData(en);

window.storiesOf = storiesOf;
window.action    = action;
window.React     = React;

let req = require.context('./stories/', true, /.story.jsx$/);

function loadStories () {
  req.keys().forEach((filename) => req(filename))
}

configure(loadStories, module);
