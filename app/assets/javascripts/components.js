import ReactRailsUJS from 'react_ujs';
import Mastodon from './components/containers/mastodon';

if (!window.Intl) {
  require('intl');
  require('intl/locale-data/jsonp/en');
}

window.Mastodon = Mastodon;
