import emojify from 'mastodon/emoji';
import { getLocale } from 'mastodon/locales';
import { length } from 'stringz';
import IntlRelativeFormat from 'intl-relativeformat';
import { delegate } from 'rails-ujs';

require.context('../images/', true);

const { localeData } = getLocale();
localeData.forEach(IntlRelativeFormat.__addLocaleData);

function main() {
  const locale = document.documentElement.lang;
  const dateTimeFormat = new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
  });
  const relativeFormat = new IntlRelativeFormat(locale);

  document.addEventListener('DOMContentLoaded', () => {
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
      content.textContent = relativeFormat.format(datetime);;
    });
  });

  delegate(document, '.video-player video', 'click', ({ target }) => {
    if (target.paused) {
      target.play();
    } else {
      target.pause();
    }
  });

  delegate(document, '.media-spoiler', 'click', ({ target }) => {
    target.style.display = 'none';
  });

  delegate(document, '.webapp-btn', 'click', ({ target, button }) => {
    if (button !== 0) {
      return true;
    }
    window.location.href = target.href;
    return false;
  });

  delegate(document, '.status__content__spoiler-link', 'click', ({ target }) => {
    const contentEl = target.parentNode.parentNode.querySelector('.e-content');
    if (contentEl.style.display === 'block') {
      contentEl.style.display = 'none';
      target.parentNode.style.marginBottom = 0;
    } else {
      contentEl.style.display = 'block';
      target.parentNode.style.marginBottom = null;
    }
    return false;
  });

  delegate(document, '.account_display_name', 'input', ({ target }) => {
    const nameCounter = document.querySelector('.name-counter');
    if (nameCounter) {
      nameCounter.textContent = 30 - length(target.value);
    }
  });

  delegate(document, '.account_note', 'input', ({ target }) => {
    const noteCounter = document.querySelector('.note-counter');
    if (noteCounter) {
      noteCounter.textContent = 160 - length(target.value);
    }
  });
}

if (!window.Intl) {
  import(/* webpackChunkName: "base_polyfills" */ 'mastodon/base_polyfills').then(() => {
    main();
  }).catch(error => {
    console.log(error); // eslint-disable-line no-console
  });
} else {
  main();
}
