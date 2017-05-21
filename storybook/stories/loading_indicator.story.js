import React from 'react';
import { IntlProvider } from 'react-intl';
import { storiesOf } from '@kadira/storybook';
import getMessagesForLocale from 'mastodon/locales';
import LoadingIndicator from 'mastodon/components/loading_indicator';

storiesOf('LoadingIndicator', module)
  .add('default state', () => (
    <IntlProvider locale='en' messages={getMessagesForLocale('en')}>
      <LoadingIndicator />
    </IntlProvider>
  ));
