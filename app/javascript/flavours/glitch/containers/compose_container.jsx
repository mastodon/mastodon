import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { IntlProvider, addLocaleData } from 'react-intl';

import { Provider } from 'react-redux';

import { fetchCustomEmojis } from 'flavours/glitch/actions/custom_emojis';
import { hydrateStore } from 'flavours/glitch/actions/store';
import Compose from 'flavours/glitch/features/standalone/compose';
import initialState from 'flavours/glitch/initial_state';
import { store } from 'flavours/glitch/store';

import { getLocale } from 'mastodon/locales';

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
