import React from 'react';
import { Provider, connect } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import { showOnboardingOnce } from '../actions/onboarding';
import { BrowserRouter, Route } from 'react-router-dom';
import { ScrollContext } from 'react-router-scroll-4';
import UI from '../features/ui';
import Introduction from '../features/introduction';
import { fetchCustomEmojis } from '../actions/custom_emojis';
import { hydrateStore } from '../actions/store';
import { connectUserStream } from '../actions/streaming';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import initialState from '../initial_state';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export const store = configureStore();
const hydrateAction = hydrateStore(initialState);

store.dispatch(hydrateAction);
store.dispatch(fetchCustomEmojis());

const mapStateToProps = state => ({
  showIntroduction: !state.getIn(['settings', 'onboarded'], false),
});

@connect(mapStateToProps)
class MastodonMount extends React.Component {

  static propTypes = {
    showIntroduction: PropTypes.bool,
  };

  render () {
    const { showIntroduction } = this.props;

    if (showIntroduction) {
      return <Introduction />;
    }

    return (
      <ScrollContext>
        <Route path='/' component={UI} />
      </ScrollContext>
    );
  }

}

export default class Mastodon extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  componentDidMount() {
    this.disconnect = store.dispatch(connectUserStream());

    // Desktop notifications
    // Ask after 2 minutes
    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      window.setTimeout(() => Notification.requestPermission(), 120 * 1000);
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <BrowserRouter basename='/web'>
            <MastodonMount />
          </BrowserRouter>
        </Provider>
      </IntlProvider>
    );
  }

}
