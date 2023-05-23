import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { IntlProvider, addLocaleData } from 'react-intl';

import { Provider } from 'react-redux';

import { fetchCustomEmojis } from '../actions/custom_emojis';
import { hydrateStore } from '../actions/store';
import Compose from '../features/standalone/compose';
import initialState from '../initial_state';
import { getLocale } from '../locales';
import { store } from '../store';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

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
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <Compose />
        </Provider>
      </IntlProvider>
    );
  }

}
