import React from 'react';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import { store } from 'flavours/glitch/store';
import { hydrateStore } from 'flavours/glitch/actions/store';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from 'mastodon/locales';
import Compose from 'flavours/glitch/features/standalone/compose';
import initialState from 'flavours/glitch/initial_state';
import { fetchCustomEmojis } from 'flavours/glitch/actions/custom_emojis';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

store.dispatch(fetchCustomEmojis());

export default class TimelineContainer extends React.PureComponent {

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
