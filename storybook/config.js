import { configure } from '@storybook/react';
import { addLocaleData } from 'react-intl';
import en from 'react-intl/locale-data/en';
import '../app/javascript/styles/application.scss';
import './storybook.scss';

addLocaleData(en);

let req = require.context('./stories/', true, /.story.js$/);

function loadStories () {
  req.keys().forEach((filename) => req(filename));
}

configure(loadStories, module);
