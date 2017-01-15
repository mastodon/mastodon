import { Provider } from 'react-redux';
import configureStore from '../store/configureStore';
import {
  refreshTimelineSuccess,
  updateTimeline,
  deleteFromTimelines,
  refreshTimeline
} from '../actions/timelines';
import { updateNotifications } from '../actions/notifications';
import createBrowserHistory from 'history/lib/createBrowserHistory';
import {
  applyRouterMiddleware,
  useRouterHistory,
  Router,
  Route,
  IndexRedirect,
  IndexRoute
} from 'react-router';
import { useScroll } from 'react-router-scroll';
import UI from '../features/ui';
import Account from '../features/account';
import Status from '../features/status';
import GettingStarted from '../features/getting_started';
import PublicTimeline from '../features/public_timeline';
import AccountTimeline from '../features/account_timeline';
import HomeTimeline from '../features/home_timeline';
import MentionsTimeline from '../features/mentions_timeline';
import Compose from '../features/compose';
import Followers from '../features/followers';
import Following from '../features/following';
import Reblogs from '../features/reblogs';
import Favourites from '../features/favourites';
import HashtagTimeline from '../features/hashtag_timeline';
import Notifications from '../features/notifications';
import FollowRequests from '../features/follow_requests';
import GenericNotFound from '../features/generic_not_found';
import { IntlProvider, addLocaleData } from 'react-intl';
import en from 'react-intl/locale-data/en';
import de from 'react-intl/locale-data/de';
import es from 'react-intl/locale-data/es';
import fr from 'react-intl/locale-data/fr';
import pt from 'react-intl/locale-data/pt';
import hu from 'react-intl/locale-data/hu';
import uk from 'react-intl/locale-data/uk';
import getMessagesForLocale from '../locales';
import { hydrateStore } from '../actions/store';

const store = configureStore();

store.dispatch(hydrateStore(window.INITIAL_STATE));

const browserHistory = useRouterHistory(createBrowserHistory)({
  basename: '/web'
});

addLocaleData([...en, ...de, ...es, ...fr, ...pt, ...hu, ...uk]);

const Mastodon = React.createClass({

  propTypes: {
    locale: React.PropTypes.string.isRequired
  },

  componentWillMount() {
    const { locale } = this.props;

    if (typeof App !== 'undefined') {
      this.subscription = App.cable.subscriptions.create('TimelineChannel', {

        received (data) {
          switch(data.type) {
          case 'update':
            store.dispatch(updateTimeline(data.timeline, JSON.parse(data.message)));
            break;
          case 'delete':
            store.dispatch(deleteFromTimelines(data.id));
            break;
          case 'notification':
            store.dispatch(updateNotifications(JSON.parse(data.message), getMessagesForLocale(locale), locale));
            break;
          }
        }

      });
    }

    // Desktop notifications
    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      Notification.requestPermission();
    }
  },

  componentWillUnmount () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.unsubscribe();
    }
  },

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={getMessagesForLocale(locale)}>
        <Provider store={store}>
          <Router history={browserHistory} render={applyRouterMiddleware(useScroll())}>
            <Route path='/' component={UI}>
              <IndexRedirect to="/getting-started" />

              <Route path='getting-started' component={GettingStarted} />
              <Route path='timelines/home' component={HomeTimeline} />
              <Route path='timelines/mentions' component={MentionsTimeline} />
              <Route path='timelines/public' component={PublicTimeline} />
              <Route path='timelines/tag/:id' component={HashtagTimeline} />

              <Route path='notifications' component={Notifications} />

              <Route path='statuses/new' component={Compose} />
              <Route path='statuses/:statusId' component={Status} />
              <Route path='statuses/:statusId/reblogs' component={Reblogs} />
              <Route path='statuses/:statusId/favourites' component={Favourites} />

              <Route path='accounts/:accountId' component={Account}>
                <IndexRoute component={AccountTimeline} />
                <Route path='followers' component={Followers} />
                <Route path='following' component={Following} />
              </Route>

              <Route path='follow_requests' component={FollowRequests} />
              <Route path='*' component={GenericNotFound} />
            </Route>
          </Router>
        </Provider>
      </IntlProvider>
    );
  }

});

export default Mastodon;
