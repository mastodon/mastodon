import loadPolyfills from 'flavours/glitch/util/load_polyfills';
import ready from 'flavours/glitch/util/ready';

function main() {
  const IntlRelativeFormat = require('intl-relativeformat').default;
  const emojify = require('flavours/glitch/util/emoji').default;
  const { getLocale } = require('locales');
  const { localeData } = getLocale();
  const React = require('react');
  const ReactDOM = require('react-dom');

  localeData.forEach(IntlRelativeFormat.__addLocaleData);

  ready(() => {
    const locale = document.documentElement.lang;

    const dateTimeFormat = new Intl.DateTimeFormat(locale, {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
    });

    const relativeFormat = new IntlRelativeFormat(locale);

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

      content.title = dateTimeFormat.format(datetime);
      content.textContent = relativeFormat.format(datetime);
    });

    [].forEach.call(document.querySelectorAll('.logo-button'), (content) => {
      content.addEventListener('click', (e) => {
        e.preventDefault();
        window.open(e.target.href, 'mastodon-intent', 'width=400,height=400,resizable=no,menubar=no,status=no,scrollbars=yes');
      });
    });

    const reactComponents = document.querySelectorAll('[data-component]');
    if (reactComponents.length > 0) {
      import(/* webpackChunkName: "containers/media_container" */ 'flavours/glitch/containers/media_container')
        .then(({ default: MediaContainer }) => {
          const content = document.createElement('div');
          ReactDOM.render(<MediaContainer locale={locale} components={reactComponents} />, content);
          document.body.appendChild(content);
        })
        .catch(error => console.error(error));
    }
  });
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
