import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { IntlProvider } from 'react-intl';

import { Provider } from 'react-redux';

import { fetchCustomEmojis } from '../actions/custom_emojis';
import { hydrateStore } from '../actions/store';
import Compose from '../features/standalone/compose';
import initialState from '../initial_state';
import { getLocale, onProviderError } from '../locales';
import { store } from '../store';

const { messages } = getLocale();

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

store.dispatch(fetchCustomEmojis());

export default class TimelineContainer extends PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages} onError={onProviderError}>
        <Provider store={store}>
          <Compose />
        </Provider>
      </IntlProvider>
    );
  }

}
