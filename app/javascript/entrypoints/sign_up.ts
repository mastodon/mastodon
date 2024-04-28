import './public-path';
import axios from 'axios';

import ready from '../mastodon/ready';

async function checkConfirmation() {
  const response = await axios.get('/api/v1/emails/check_confirmation');

  if (response.data) {
    window.location.href = '/start';
  }
}

ready(() => {
  setInterval(() => {
    void checkConfirmation();
  }, 5000);

  document
    .querySelectorAll<HTMLButtonElement>('button.timer-button')
    .forEach((button) => {
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
}).catch((e: unknown) => {
  throw e;
});
