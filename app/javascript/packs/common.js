import { start } from 'rails-ujs';

// import default stylesheet with variables
require('font-awesome/css/font-awesome.css');
require('mastodon-application-style');

require.context('../images/', true);

start();
