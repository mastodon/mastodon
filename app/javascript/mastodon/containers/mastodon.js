import React from 'react';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import {
  refreshTimelineSuccess,
  updateTimeline,
  deleteFromTimelines,
  refreshTimeline,
  connectTimeline,
  disconnectTimeline,
} from '../actions/timelines';
import { showOnboardingOnce } from '../actions/onboarding';
import { updateNotifications, refreshNotifications } from '../actions/notifications';
import createBrowserHistory from 'history/lib/createBrowserHistory';
import applyRouterMiddleware from 'react-router/lib/applyRouterMiddleware';
import useRouterHistory from 'react-router/lib/useRouterHistory';
import Router from 'react-router/lib/Router';
import { useScroll } from 'react-router-scroll';
import { hydrateStore } from '../actions/store';
import createStream from '../stream';
import routes from './routes';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
const { localeData, messages } = getLocale();
addLocaleData(localeData);

const store = configureStore();
const initialState = JSON.parse(document.getElementById("initial-state").textContent);
store.dispatch(hydrateStore(initialState));

const browserHistory = useRouterHistory(createBrowserHistory)({
  basename: '/web',
});

class Mastodon extends React.PureComponent {

  componentDidMount() {
    const { locale }  = this.props;
    const streamingAPIBaseURL = store.getState().getIn(['meta', 'streaming_api_base_url']);
    const accessToken = store.getState().getIn(['meta', 'access_token']);

    const setupPolling = () => {
      this.polling = setInterval(() => {
        store.dispatch(refreshTimeline('home'));
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
        store.dispatch(refreshTimeline('home'));
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
          <Router history={browserHistory} routes={routes} render={applyRouterMiddleware(useScroll())} />
        </Provider>
      </IntlProvider>
    );
  }

}

Mastodon.propTypes = {
  locale: PropTypes.string.isRequired,
};

export default Mastodon;
