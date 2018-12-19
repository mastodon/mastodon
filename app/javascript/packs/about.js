import loadPolyfills from '../mastodon/load_polyfills';
import { start } from '../mastodon/common';
import { getLocale } from '../mastodon/locales';
import { addLocaleData, IntlProvider } from 'react-intl';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

start();

function loaded() {
  const TimelineContainer = require('../mastodon/containers/timeline_container').default;
  const FormContainer     = require('../mastodon/containers/registration_form_container').default;
  const React             = require('react');
  const ReactDOM          = require('react-dom');
  const formMoutNode      = document.getElementById('mastodon-registration-form');
  const timelineMountNode = document.getElementById('mastodon-timeline');

  if (timelineMountNode !== null) {
    const props = JSON.parse(timelineMountNode.getAttribute('data-props'));
    ReactDOM.render(<TimelineContainer {...props} />, timelineMountNode);
  }

  if (formMoutNode!== null) {
    const props = JSON.parse(formMoutNode.getAttribute('data-props'));
    ReactDOM.render(
      <IntlProvider locale={props.locale} messages={messages}>
        <FormContainer {...props} />
      </IntlProvider>
      , formMoutNode);
  }
}

function main() {
  const ready = require('../mastodon/ready').default;
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
