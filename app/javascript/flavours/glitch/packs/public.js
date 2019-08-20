import loadPolyfills from 'flavours/glitch/util/load_polyfills';
import ready from 'flavours/glitch/util/ready';

function main() {
  const IntlMessageFormat = require('intl-messageformat').default;
  const { timeAgoString } = require('flavours/glitch/components/relative_timestamp');
  const { delegate } = require('rails-ujs');
  const emojify = require('flavours/glitch/util/emoji').default;
  const { getLocale } = require('locales');
  const { messages } = getLocale();
  const React = require('react');
  const ReactDOM = require('react-dom');
  const Rellax = require('rellax');
  const createHistory = require('history').createBrowserHistory;

  const scrollToDetailedStatus = () => {
    const history = createHistory();
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
      }, datetime, now, now.getFullYear());
    });

    const reactComponents = document.querySelectorAll('[data-component]');
    if (reactComponents.length > 0) {
      import(/* webpackChunkName: "containers/media_container" */ 'flavours/glitch/containers/media_container')
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

    if (document.body.classList.contains('with-modals')) {
      const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
      const scrollbarWidthStyle = document.createElement('style');
      scrollbarWidthStyle.id = 'scrollbar-width';
      document.head.appendChild(scrollbarWidthStyle);
      scrollbarWidthStyle.sheet.insertRule(`body.with-modals--active { margin-right: ${scrollbarWidth}px; }`, 0);
    }

    delegate(document, '.custom-emoji', 'mouseover', getEmojiAnimationHandler('data-original'));
    delegate(document, '.custom-emoji', 'mouseout', getEmojiAnimationHandler('data-static'));

    delegate(document, '.blocks-table button.icon-button', 'click', function(e) {
      e.preventDefault();

      const classList = this.firstElementChild.classList;
      classList.toggle('fa-chevron-down');
      classList.toggle('fa-chevron-up');
      this.parentElement.parentElement.nextElementSibling.classList.toggle('hidden');
    });
  });
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
