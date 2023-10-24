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

  document.querySelectorAll('.timer-button').forEach(button => {
    let counter = 30;

    const container = document.createElement('span');

    const updateCounter = () => {
      container.innerText = ` (${counter})`;
    };

    updateCounter();

    const countdown = setInterval(() => {
      counter--;

      if (counter === 0) {
        button.disabled = false;
        button.removeChild(container);
        clearInterval(countdown);
      } else {
        updateCounter();
      }
    }, 1000);

    button.appendChild(container);
  });
});
