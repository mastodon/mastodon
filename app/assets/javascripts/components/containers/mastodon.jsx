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
import en from 'react-intl/locale-data/en';
import de from 'react-intl/locale-data/de';
import eo from 'react-intl/locale-data/eo';
import es from 'react-intl/locale-data/es';
import fi from 'react-intl/locale-data/fi';
import fr from 'react-intl/locale-data/fr';
import hu from 'react-intl/locale-data/hu';
import it from 'react-intl/locale-data/it';
import ja from 'react-intl/locale-data/ja';
import pt from 'react-intl/locale-data/pt';
import nl from 'react-intl/locale-data/nl';
import no from 'react-intl/locale-data/no';
import ru from 'react-intl/locale-data/ru';
import uk from 'react-intl/locale-data/uk';
import zh from 'react-intl/locale-data/zh';
import bg from 'react-intl/locale-data/bg';
import id from 'react-intl/locale-data/id';
import { localeData as zh_hk } from '../locales/zh-hk';
import { localeData as zh_cn } from '../locales/zh-cn';
import pt_br from '../locales/pt-br';
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
  ...en,
  ...ar,
  ...de,
  ...eo,
  ...es,
  ...fi,
  ...fr,
  ...hu,
  ...it,
  ...ja,
  ...pt,
  ...pt_br,
  ...nl,
  ...no,
  ...ru,
  ...uk,
  ...zh,
  ...zh_hk,
  ...zh_cn,
  ...bg,
  ...id,
]);

const getTopWhenReplacing = (previous, { location }) => location && location.action === 'REPLACE' && [0, 0];

const hiddenColumnContainerStyle = {
  position: 'absolute',
  left: '0',
  top:  '0',
  visibility: 'hidden'
};

class Container extends React.PureComponent {

  constructor(props) {
    super(props);

    this.state = {
      renderedPersistents: [],
      unrenderedPersistents: [],
    };
  }

  componentWillMount () {
    this.unlistenHistory = null;

    this.setState(() => {
      return {
        mountImpersistent: false,
        renderedPersistents: [],
        unrenderedPersistents: [
          {pathname: '/timelines/home', component: HomeTimeline},
          {pathname: '/timelines/public', component: PublicTimeline},
          {pathname: '/timelines/public/local', component: CommunityTimeline},

          {pathname: '/notifications', component: Notifications},
          {pathname: '/favourites', component: FavouritedStatuses}
        ],
      };
    }, () => {
      if (this.unlistenHistory) {
        return;
      }

      this.unlistenHistory = browserHistory.listen(location => {
        const pathname = location.pathname.replace(/\/$/, '').toLowerCase();

        this.setState(oldState => {
          let persistentMatched = false;

          const newState = {
            renderedPersistents: oldState.renderedPersistents.map(persistent => {
              const givenMatched = persistent.pathname === pathname;

              if (givenMatched) {
                persistentMatched = true;
              }

              return {
                hidden: !givenMatched,
                pathname: persistent.pathname,
                component: persistent.component
              };
            }),
          };

          if (!persistentMatched) {
            newState.unrenderedPersistents = [];

            oldState.unrenderedPersistents.forEach(persistent => {
              if (persistent.pathname === pathname) {
                persistentMatched = true;

                newState.renderedPersistents.push({
                  hidden: false,
                  pathname: persistent.pathname,
                  component: persistent.component
                });
              } else {
                newState.unrenderedPersistents.push(persistent);
              }
            });
          }

          newState.mountImpersistent = !persistentMatched;

          return newState;
        });
      });
    });
  }

  componentWillUnmount () {
    if (this.unlistenHistory) {
      this.unlistenHistory();
    }

    this.unlistenHistory = "done";
  }

  render () {
    // Hide some components rather than unmounting them to allow to show again
    // quickly and keep the view state such as the scrolled offset.
    const persistentsView = this.state.renderedPersistents.map((persistent) =>
      <div aria-hidden={persistent.hidden} key={persistent.pathname} className='mastodon-column-container' style={persistent.hidden ? hiddenColumnContainerStyle : null}>
        <persistent.component shouldUpdateScroll={persistent.hidden ? Function.prototype : getTopWhenReplacing} />
      </div>
    );

    return (
      <UI>
        {this.state.mountImpersistent && this.props.children}
        {persistentsView}
      </UI>
    );
  }
}

Container.propTypes = {
  children: PropTypes.node,
};

class Mastodon extends React.Component {

  componentDidMount() {
    const { locale }  = this.props;
    const streamingAPIBaseURL = store.getState().getIn(['meta', 'streaming_api_base_url']);
    const accessToken = store.getState().getIn(['meta', 'access_token']);

    this.subscription = createStream(streamingAPIBaseURL, accessToken, 'user', {

      connected () {
        store.dispatch(connectTimeline('home'));
      },

      disconnected () {
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
  }

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={getMessagesForLocale(locale)}>
        <Provider store={store}>
          <Router history={browserHistory} render={applyRouterMiddleware(useScroll())}>
            <Route path='/' component={Container}>
              <IndexRedirect to="/getting-started" />

              <Route path='getting-started' component={GettingStarted} />
              <Route path='timelines/tag/:id' component={HashtagTimeline} />

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
