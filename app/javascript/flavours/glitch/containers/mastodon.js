import React from 'react';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from 'flavours/glitch/store/configureStore';
import { showOnboardingOnce } from 'flavours/glitch/actions/onboarding';
import { BrowserRouter, Route } from 'react-router-dom';
import { ScrollContext } from 'react-router-scroll-4';
import UI from 'flavours/glitch/features/ui';
import { fetchCustomEmojis } from 'flavours/glitch/actions/custom_emojis';
import { hydrateStore } from 'flavours/glitch/actions/store';
import { connectUserStream } from 'flavours/glitch/actions/streaming';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from 'locales';
import initialState from 'flavours/glitch/util/initial_state';
import ErrorBoundary from 'flavours/glitch/components/error_boundary';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export const store = configureStore();
const hydrateAction = hydrateStore(initialState);
store.dispatch(hydrateAction);

// load custom emojis
store.dispatch(fetchCustomEmojis());

export default class Mastodon extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  componentDidMount() {
    this.disconnect = store.dispatch(connectUserStream());

    // Desktop notifications
    // Ask after 1 minute
    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      window.setTimeout(() => Notification.requestPermission(), 60 * 1000);
    }

    store.dispatch(showOnboardingOnce());
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  shouldUpdateScroll (_, { location }) {
    return !(location.state && location.state.mastodonModalOpen);
  }

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <ErrorBoundary>
            <BrowserRouter basename='/web'>
              <ScrollContext shouldUpdateScroll={this.shouldUpdateScroll}>
                <Route path='/' component={UI} />
              </ScrollContext>
            </BrowserRouter>
          </ErrorBoundary>
        </Provider>
      </IntlProvider>
    );
  }

}
