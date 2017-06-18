import React from 'react';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import {
  refreshTimelineSuccess,
  updateTimeline,
  deleteFromTimelines,
  refreshHomeTimeline,
  connectTimeline,
  disconnectTimeline,
} from '../actions/timelines';
import { showOnboardingOnce } from '../actions/onboarding';
import { updateNotifications, refreshNotifications } from '../actions/notifications';
import createBrowserHistory from 'history/lib/createBrowserHistory';
import applyRouterMiddleware from 'react-router/lib/applyRouterMiddleware';
import useRouterHistory from 'react-router/lib/useRouterHistory';
import Router from 'react-router/lib/Router';
import Route from 'react-router/lib/Route';
import IndexRedirect from 'react-router/lib/IndexRedirect';
import IndexRoute from 'react-router/lib/IndexRoute';
import { useScroll } from 'react-router-scroll';
import UI from '../features/ui';
import Status from '../features/status';
import GettingStarted from '../features/getting_started';
import PublicTimeline from '../features/public_timeline';
import CommunityTimeline from '../features/community_timeline';
import AccountTimeline from '../features/account_timeline';
import AccountGallery from '../features/account_gallery';
import HomeTimeline from '../features/home_timeline';
import Compose from '../features/compose';
import Followers from '../features/followers';
import Following from '../features/following';
import Reblogs from '../features/reblogs';
import Favourites from '../features/favourites';
import HashtagTimeline from '../features/hashtag_timeline';
import Notifications from '../features/notifications';
import FollowRequests from '../features/follow_requests';
import GenericNotFound from '../features/generic_not_found';
import FavouritedStatuses from '../features/favourited_statuses';
import Blocks from '../features/blocks';
import Mutes from '../features/mutes';
import Report from '../features/report';
import { hydrateStore } from '../actions/store';
import createStream from '../stream';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
const { localeData, messages } = getLocale();
addLocaleData(localeData);

const store = configureStore();
const initialState = JSON.parse(document.getElementById('initial-state').textContent);
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
          <Router history={browserHistory} render={applyRouterMiddleware(useScroll())}>
            <Route path='/' component={UI}>
              <IndexRedirect to='/getting-started' />
              <Route path='getting-started' component={GettingStarted} />
              <Route path='timelines/home' component={HomeTimeline} />
              <Route path='timelines/public' component={PublicTimeline} />
              <Route path='timelines/public/local' component={CommunityTimeline} />
              <Route path='timelines/tag/:id' component={HashtagTimeline} />

              <Route path='notifications' component={Notifications} />
              <Route path='favourites' component={FavouritedStatuses} />

              <Route path='statuses/new' component={Compose} />
              <Route path='statuses/:statusId' component={Status} />
              <Route path='statuses/:statusId/reblogs' component={Reblogs} />
              <Route path='statuses/:statusId/favourites' component={Favourites} />

              <Route path='accounts/:accountId' component={AccountTimeline} />
              <Route path='accounts/:accountId/followers' component={Followers} />
              <Route path='accounts/:accountId/following' component={Following} />
              <Route path='accounts/:accountId/media' component={AccountGallery} />

              <Route path='follow_requests' component={FollowRequests} />
              <Route path='blocks' component={Blocks} />
              <Route path='mutes' component={Mutes} />
              <Route path='report' component={Report} />

              <Route path='*' component={GenericNotFound} />
            </Route>
          </Router>
        </Provider>
      </IntlProvider>
    );
  }

}

Mastodon.propTypes = {
  locale: PropTypes.string.isRequired,
};

export default Mastodon;
