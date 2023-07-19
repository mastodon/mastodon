import './public-path';
import axios from 'axios';

import ready from '../mastodon/ready';

ready(() => {
  setInterval(() => {
    axios.get('/api/v1/emails/check_confirmation').then((response) => {
      if (response.data) {
        window.location = '/start';
      }
    }).catch(error => {
      console.error(error);
    });
  }, 5000);
});
