import React from 'react';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import {
  updateTimeline,
  deleteFromTimelines,
  refreshHomeTimeline,
  connectTimeline,
  disconnectTimeline,
} from '../actions/timelines';
import { showOnboardingOnce } from '../actions/onboarding';
import { updateNotifications, refreshNotifications } from '../actions/notifications';
import BrowserRouter from 'react-router-dom/BrowserRouter';
import Route from 'react-router-dom/Route';
import ScrollContext from 'react-router-scroll/lib/ScrollBehaviorContext';
import UI from '../features/ui';
import { hydrateStore } from '../actions/store';
import createStream from '../stream';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
const { localeData, messages } = getLocale();
addLocaleData(localeData);

const store = configureStore();
const initialState = JSON.parse(document.getElementById('initial-state').textContent);
store.dispatch(hydrateStore(initialState));

export default class Mastodon extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  componentDidMount() {
    const { locale }  = this.props;
    const streamingAPIBaseURL = store.getState().getIn(['meta', 'streaming_api_base_url']);
    const accessToken = store.getState().getIn(['meta', 'access_token']);

    const setupPolling = () => {
      this.polling = setInterval(() => {
        store.dispatch(refreshHomeTimeline());
        store.dispatch(refreshNotifications());
      }, 20000);
    };

    const clearPolling = () => {
      clearInterval(this.polling);
      this.polling = undefined;
    };

    this.subscription = createStream(streamingAPIBaseURL, accessToken, 'user', {

      connected () {
        clearPolling();
        store.dispatch(connectTimeline('home'));
      },

      disconnected () {
        setupPolling();
        store.dispatch(disconnectTimeline('home'));
      },

      received (data) {
        switch(data.event) {
        case 'update':
          store.dispatch(updateTimeline('home', JSON.parse(data.payload)));
          break;
        case 'delete':
          store.dispatch(deleteFromTimelines(data.payload));
          break;
        case 'notification':
          store.dispatch(updateNotifications(JSON.parse(data.payload), messages, locale));
          break;
        }
      },

      reconnected () {
        clearPolling();
        store.dispatch(connectTimeline('home'));
        store.dispatch(refreshHomeTimeline());
        store.dispatch(refreshNotifications());
      },

    });

    // Desktop notifications
    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      Notification.requestPermission();
    }

    store.dispatch(showOnboardingOnce());
  }

  componentWillUnmount () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.close();
      this.subscription = null;
    }

    if (typeof this.polling !== 'undefined') {
      clearInterval(this.polling);
      this.polling = null;
    }
  }

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <BrowserRouter basename='/web'>
            <ScrollContext>
              <Route path='/' component={UI} />
            </ScrollContext>
          </BrowserRouter>
        </Provider>
      </IntlProvider>
    );
  }

}
