import './public-path';
import escapeTextContentForBrowser from 'escape-html';
import loadPolyfills from '../mastodon/load_polyfills';
import ready from '../mastodon/ready';
import { start } from '../mastodon/common';
import loadKeyboardExtensions from '../mastodon/load_keyboard_extensions';
import 'cocoon-js-vanilla';

start();

window.addEventListener('message', e => {
  const data = e.data || {};

  if (!window.parent || data.type !== 'setHeight') {
    return;
  }

  ready(() => {
    window.parent.postMessage({
      type: 'setHeight',
      id: data.id,
      height: document.getElementsByTagName('html')[0].scrollHeight,
    }, '*');
  });
});

function main() {
  const IntlMessageFormat = require('intl-messageformat').default;
  const { timeAgoString } = require('../mastodon/components/relative_timestamp');
  const { delegate } = require('@rails/ujs');
  const emojify = require('../mastodon/features/emoji/emoji').default;
  const { getLocale } = require('../mastodon/locales');
  const { messages } = getLocale();
  const React = require('react');
  const ReactDOM = require('react-dom');
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

    const dateFormat = new Intl.DateTimeFormat(locale, {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      timeFormat: false,
    });

    const timeFormat = new Intl.DateTimeFormat(locale, {
      timeStyle: 'short',
      hour12: false,
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

    const isToday = date => {
      const today = new Date();

      return date.getDate() === today.getDate() &&
        date.getMonth() === today.getMonth() &&
        date.getFullYear() === today.getFullYear();
    };
    const todayFormat = new IntlMessageFormat(messages['relative_format.today'] || 'Today at {time}', locale);

    [].forEach.call(document.querySelectorAll('time.relative-formatted'), (content) => {
      const datetime = new Date(content.getAttribute('datetime'));

      let formattedContent;

      if (isToday(datetime)) {
        const formattedTime = timeFormat.format(datetime);

        formattedContent = todayFormat.format({ time: formattedTime });
      } else {
        formattedContent = dateFormat.format(datetime);
      }

      content.title = formattedContent;
      content.textContent = formattedContent;
    });

    [].forEach.call(document.querySelectorAll('time.time-ago'), (content) => {
      const datetime = new Date(content.getAttribute('datetime'));
      const now      = new Date();

      const timeGiven = content.getAttribute('datetime').includes('T');
      content.title = timeGiven ? dateTimeFormat.format(datetime) : dateFormat.format(datetime);
      content.textContent = timeAgoString({
        formatMessage: ({ id, defaultMessage }, values) => (new IntlMessageFormat(messages[id] || defaultMessage, locale)).format(values),
        formatDate: (date, options) => (new Intl.DateTimeFormat(locale, options)).format(date),
      }, datetime, now, now.getFullYear(), timeGiven);
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

    delegate(document, '#registration_user_password_confirmation,#registration_user_password', 'input', () => {
      const password = document.getElementById('registration_user_password');
      const confirmation = document.getElementById('registration_user_password_confirmation');
      if (confirmation.value && confirmation.value.length > password.maxLength) {
        confirmation.setCustomValidity((new IntlMessageFormat(messages['password_confirmation.exceeds_maxlength'] || 'Password confirmation exceeds the maximum password length', locale)).format());
      } else if (password.value && password.value !== confirmation.value) {
        confirmation.setCustomValidity((new IntlMessageFormat(messages['password_confirmation.mismatching'] || 'Password confirmation does not match', locale)).format());
      } else {
        confirmation.setCustomValidity('');
      }
    });

    delegate(document, '#user_password,#user_password_confirmation', 'input', () => {
      const password = document.getElementById('user_password');
      const confirmation = document.getElementById('user_password_confirmation');
      if (!confirmation) return;

      if (confirmation.value && confirmation.value.length > password.maxLength) {
        confirmation.setCustomValidity((new IntlMessageFormat(messages['password_confirmation.exceeds_maxlength'] || 'Password confirmation exceeds the maximum password length', locale)).format());
      } else if (password.value && password.value !== confirmation.value) {
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

  delegate(document, '#account_display_name', 'input', ({ target }) => {
    const name = document.querySelector('.card .display-name strong');
    if (name) {
      if (target.value) {
        name.innerHTML = emojify(escapeTextContentForBrowser(target.value));
      } else {
        name.textContent = target.dataset.default;
      }
    }
  });

  delegate(document, '#account_avatar', 'change', ({ target }) => {
    const avatar = document.querySelector('.card .avatar img');
    const [file] = target.files || [];
    const url = file ? URL.createObjectURL(file) : avatar.dataset.originalSrc;

    avatar.src = url;
  });

  const getProfileAvatarAnimationHandler = (swapTo) => {
    //animate avatar gifs on the profile page when moused over
    return ({ target }) => {
      const swapSrc = target.getAttribute(swapTo);
      //only change the img source if autoplay is off and the image src is actually different
      if(target.getAttribute('data-autoplay') !== 'true' && target.src !== swapSrc) {
        target.src = swapSrc;
      }
    };
  };

  delegate(document, 'img#profile_page_avatar', 'mouseover', getProfileAvatarAnimationHandler('data-original'));

  delegate(document, 'img#profile_page_avatar', 'mouseout', getProfileAvatarAnimationHandler('data-static'));

  delegate(document, '#account_header', 'change', ({ target }) => {
    const header = document.querySelector('.card .card__img img');
    const [file] = target.files || [];
    const url = file ? URL.createObjectURL(file) : header.dataset.originalSrc;

    header.src = url;
  });

  delegate(document, '#account_locked', 'change', ({ target }) => {
    const lock = document.querySelector('.card .display-name i');

    if (lock) {
      if (target.checked) {
        delete lock.dataset.hidden;
      } else {
        lock.dataset.hidden = 'true';
      }
    }
  });

  delegate(document, '.input-copy input', 'click', ({ target }) => {
    target.focus();
    target.select();
    target.setSelectionRange(0, target.value.length);
  });

  delegate(document, '.input-copy button', 'click', ({ target }) => {
    const input = target.parentNode.querySelector('.input-copy__wrapper input');

    const oldReadOnly = input.readonly;

    input.readonly = false;
    input.focus();
    input.select();
    input.setSelectionRange(0, input.value.length);

    try {
      if (document.execCommand('copy')) {
        input.blur();
        target.parentNode.classList.add('copied');

        setTimeout(() => {
          target.parentNode.classList.remove('copied');
        }, 700);
      }
    } catch (err) {
      console.error(err);
    }

    input.readonly = oldReadOnly;
  });

  const toggleSidebar = () => {
    const sidebar = document.querySelector('.sidebar ul');
    const toggleButton = document.querySelector('.sidebar__toggle__icon');

    if (sidebar.classList.contains('visible')) {
      document.body.style.overflow = null;
      toggleButton.setAttribute('aria-expanded', 'false');
    } else {
      document.body.style.overflow = 'hidden';
      toggleButton.setAttribute('aria-expanded', 'true');
    }

    toggleButton.classList.toggle('active');
    sidebar.classList.toggle('visible');
  };

  delegate(document, '.sidebar__toggle__icon', 'click', () => {
    toggleSidebar();
  });

  delegate(document, '.sidebar__toggle__icon', 'keydown', e => {
    if (e.key === ' ' || e.key === 'Enter') {
      e.preventDefault();
      toggleSidebar();
    }
  });

  // Empty the honeypot fields in JS in case something like an extension
  // automatically filled them.
  delegate(document, '#registration_new_user,#new_user', 'submit', () => {
    ['user_website', 'user_confirm_password', 'registration_user_website', 'registration_user_confirm_password'].forEach(id => {
      const field = document.getElementById(id);
      if (field) {
        field.value = '';
      }
    });
  });
}

loadPolyfills()
  .then(main)
  .then(loadKeyboardExtensions)
  .catch(error => {
    console.error(error);
  });
