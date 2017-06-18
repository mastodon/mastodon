import React from 'react';
import { IntlProvider } from 'react-intl';
import { storiesOf } from '@kadira/storybook';
import en from 'mastodon/locales/en.json';
import LoadingIndicator from 'mastodon/components/loading_indicator';

storiesOf('LoadingIndicator', module)
  .add('default state', () => (
    <IntlProvider locale='en' messages={en}>
      <LoadingIndicator />
    </IntlProvider>
  ));
