import loadPolyfills from '../mastodon/load_polyfills';
import ready from '../mastodon/ready';
import { start } from '../mastodon/common';
import loadKeyboardExtensions from '../mastodon/load_keyboard_extensions';

start();

function main() {
  const IntlMessageFormat = require('intl-messageformat').default;
  const { timeAgoString } = require('../mastodon/components/relative_timestamp');
  const { delegate } = require('@rails/ujs');
  const emojify = require('../mastodon/features/emoji/emoji').default;
  const { getLocale } = require('../mastodon/locales');
  const { messages } = getLocale();
  const React = require('react');
  const ReactDOM = require('react-dom');
  const Rellax = require('rellax');
  const { createBrowserHistory } = require('history');

  const scrollToDetailedStatus = () => {
    const history = createBrowserHistory();
    const detailedStatuses = document.querySelectorAll('.public-layout .detailed-status');
    const location = history.location;

    if (detailedStatuses.length === 1 && (!location.state || !location.state.scrolledToDetailedStatus)) {
      detailedStatuses[0].scrollIntoView();
      history.replace(location.pathname, { ...location.state, scrolledToDetailedStatus: true });
    }
  };

  const getEmojiAnimationHandler = (swapTo) => {
    return ({ target }) => {
      target.src = target.getAttribute(swapTo);
    };
  };

  ready(() => {
    const locale = document.documentElement.lang;

    const dateTimeFormat = new Intl.DateTimeFormat(locale, {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
    });

    [].forEach.call(document.querySelectorAll('.emojify'), (content) => {
      content.innerHTML = emojify(content.innerHTML);
    });

    [].forEach.call(document.querySelectorAll('time.formatted'), (content) => {
      const datetime = new Date(content.getAttribute('datetime'));
      const formattedDate = dateTimeFormat.format(datetime);

      content.title = formattedDate;
      content.textContent = formattedDate;
    });

    [].forEach.call(document.querySelectorAll('time.time-ago'), (content) => {
      const datetime = new Date(content.getAttribute('datetime'));
      const now      = new Date();

      content.title = dateTimeFormat.format(datetime);
      content.textContent = timeAgoString({
        formatMessage: ({ id, defaultMessage }, values) => (new IntlMessageFormat(messages[id] || defaultMessage, locale)).format(values),
        formatDate: (date, options) => (new Intl.DateTimeFormat(locale, options)).format(date),
      }, datetime, now, now.getFullYear(), content.getAttribute('datetime').includes('T'));
    });

    const reactComponents = document.querySelectorAll('[data-component]');

    if (reactComponents.length > 0) {
      import(/* webpackChunkName: "containers/media_container" */ '../mastodon/containers/media_container')
        .then(({ default: MediaContainer }) => {
          [].forEach.call(reactComponents, (component) => {
            [].forEach.call(component.children, (child) => {
              component.removeChild(child);
            });
          });

          const content = document.createElement('div');

          ReactDOM.render(<MediaContainer locale={locale} components={reactComponents} />, content);
          document.body.appendChild(content);
          scrollToDetailedStatus();
        })
        .catch(error => {
          console.error(error);
          scrollToDetailedStatus();
        });
    } else {
      scrollToDetailedStatus();
    }

    const parallaxComponents = document.querySelectorAll('.parallax');

    if (parallaxComponents.length > 0 ) {
      new Rellax('.parallax', { speed: -1 });
    }

    delegate(document, '#registration_user_password_confirmation,#registration_user_password', 'input', () => {
      const password = document.getElementById('registration_user_password');
      const confirmation = document.getElementById('registration_user_password_confirmation');
      if (password.value && password.value !== confirmation.value) {
        confirmation.setCustomValidity((new IntlMessageFormat(messages['password_confirmation.mismatching'] || 'Password confirmation does not match', locale)).format());
      } else {
        confirmation.setCustomValidity('');
      }
    });

    delegate(document, '#user_password,#user_password_confirmation', 'input', () => {
      const password = document.getElementById('user_password');
      const confirmation = document.getElementById('user_password_confirmation');
      if (!confirmation) return;

      if (password.value && password.value !== confirmation.value) {
        confirmation.setCustomValidity((new IntlMessageFormat(messages['password_confirmation.mismatching'] || 'Password confirmation does not match', locale)).format());
      } else {
        confirmation.setCustomValidity('');
      }
    });

    delegate(document, '.custom-emoji', 'mouseover', getEmojiAnimationHandler('data-original'));
    delegate(document, '.custom-emoji', 'mouseout', getEmojiAnimationHandler('data-static'));

    delegate(document, '.status__content__spoiler-link', 'click', function() {
      const statusEl = this.parentNode.parentNode;

      if (statusEl.dataset.spoiler === 'expanded') {
        statusEl.dataset.spoiler = 'folded';
        this.textContent = (new IntlMessageFormat(messages['status.show_more'] || 'Show more', locale)).format();
      } else {
        statusEl.dataset.spoiler = 'expanded';
        this.textContent = (new IntlMessageFormat(messages['status.show_less'] || 'Show less', locale)).format();
      }

      return false;
    });

    [].forEach.call(document.querySelectorAll('.status__content__spoiler-link'), (spoilerLink) => {
      const statusEl = spoilerLink.parentNode.parentNode;
      const message = (statusEl.dataset.spoiler === 'expanded') ? (messages['status.show_less'] || 'Show less') : (messages['status.show_more'] || 'Show more');
      spoilerLink.textContent = (new IntlMessageFormat(message, locale)).format();
    });
  });

  delegate(document, '.sidebar__toggle__icon', 'click', () => {
    const target = document.querySelector('.sidebar ul');

    if (target.style.display === 'block') {
      target.style.display = 'none';
    } else {
      target.style.display = 'block';
    }
  });
}

loadPolyfills()
  .then(main)
  .then(loadKeyboardExtensions)
  .catch(error => {
    console.error(error);
  });
