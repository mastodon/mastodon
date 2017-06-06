import React from 'react';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import en from 'mastodon/locales/en.json';
import configureStore from 'mastodon/store/configureStore';
import { hydrateStore } from 'mastodon/actions/store';
import OnboadingModal from 'mastodon/features/ui/components/onboarding_modal';
import initialState from '../initial_state';

const store = configureStore();
store.dispatch(hydrateStore(initialState));

storiesOf('OnboadingModal', module)
  .add('default state', () => (
    <IntlProvider locale='en' messages={en}>
      <Provider store={store}>
        <div style={{ position: 'absolute' }}>
          <OnboadingModal onClose={action('close')} />
        </div>
      </Provider>
    </IntlProvider>
  ));
