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
  disconnectTimeline
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
import { IntlProvider, addLocaleData } from 'react-intl';
import ar from 'react-intl/locale-data/ar';
import bg from 'react-intl/locale-data/bg';
import ca from 'react-intl/locale-data/ca';
import de from 'react-intl/locale-data/de';
import en from 'react-intl/locale-data/en';
import eo from 'react-intl/locale-data/eo';
import es from 'react-intl/locale-data/es';
import fa from 'react-intl/locale-data/fa';
import fi from 'react-intl/locale-data/fi';
import fr from 'react-intl/locale-data/fr';
import he from 'react-intl/locale-data/he';
import hr from 'react-intl/locale-data/hr';
import hu from 'react-intl/locale-data/hu';
import id from 'react-intl/locale-data/id';
import it from 'react-intl/locale-data/it';
import ja from 'react-intl/locale-data/ja';
import nl from 'react-intl/locale-data/nl';
import no from 'react-intl/locale-data/no';
import oc from '../locales/locale-data/oc';
import pt from 'react-intl/locale-data/pt';
import ru from 'react-intl/locale-data/ru';
import uk from 'react-intl/locale-data/uk';
import zh from 'react-intl/locale-data/zh';
import tr from 'react-intl/locale-data/tr';
import getMessagesForLocale from '../locales';
import { hydrateStore } from '../actions/store';
import createStream from '../stream';

const store = configureStore();
const initialState = JSON.parse(document.getElementById("initial-state").textContent);
store.dispatch(hydrateStore(initialState));

const browserHistory = useRouterHistory(createBrowserHistory)({
  basename: '/web'
});

addLocaleData([
  ...ar,
  ...bg,
  ...ca,
  ...de,
  ...en,
  ...eo,
  ...es,
  ...fa,
  ...fi,
  ...fr,
  ...he,
  ...hr,
  ...hu,
  ...id,
  ...it,
  ...ja,
  ...nl,
  ...no,
  ...oc,
  ...pt,
  ...ru,
  ...uk,
  ...zh,
  ...tr,
]);

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
          store.dispatch(updateNotifications(JSON.parse(data.payload), getMessagesForLocale(locale), locale));
          break;
        }
      },

      reconnected () {
        clearPolling();
        store.dispatch(connectTimeline('home'));
        store.dispatch(refreshTimeline('home'));
        store.dispatch(refreshNotifications());
      }

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
      <IntlProvider locale={locale} messages={getMessagesForLocale(locale)}>
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
  locale: PropTypes.string.isRequired
};

export default Mastodon;
