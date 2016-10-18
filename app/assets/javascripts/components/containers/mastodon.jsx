import { Provider }       from 'react-redux';
import configureStore     from '../store/configureStore';
import {
  refreshTimelineSuccess,
  updateTimeline,
  deleteFromTimelines,
  refreshTimeline
}                         from '../actions/timelines';
import { setAccessToken } from '../actions/meta';
import { setAccountSelf } from '../actions/accounts';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import {
  applyRouterMiddleware,
  Router,
  Route,
  hashHistory,
  IndexRoute
}                         from 'react-router';
import { useScroll }      from 'react-router-scroll';
import UI                 from '../features/ui';
import Account            from '../features/account';
import Status             from '../features/status';
import GettingStarted     from '../features/getting_started';
import PublicTimeline     from '../features/public_timeline';
import AccountTimeline    from '../features/account_timeline';
import HomeTimeline       from '../features/home_timeline';
import MentionsTimeline   from '../features/mentions_timeline';
import Compose            from '../features/compose';

const store = configureStore();

const Mastodon = React.createClass({

  propTypes: {
    token: React.PropTypes.string.isRequired,
    timelines: React.PropTypes.object,
    account: React.PropTypes.string
  },

  mixins: [PureRenderMixin],

  componentWillMount() {
    store.dispatch(setAccessToken(this.props.token));
    store.dispatch(setAccountSelf(JSON.parse(this.props.account)));

    if (typeof App !== 'undefined') {
      this.subscription = App.cable.subscriptions.create('TimelineChannel', {

        received (data) {
          switch(data.type) {
            case 'update':
              return store.dispatch(updateTimeline(data.timeline, JSON.parse(data.message)));
            case 'delete':
              return store.dispatch(deleteFromTimelines(data.id));
            case 'merge':
            case 'unmerge':
              return store.dispatch(refreshTimeline('home'));
            case 'block':
              return store.dispatch(refreshTimeline('mentions'));
          }
        }

      });
    }
  },

  componentWillUnmount () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.unsubscribe();
    }
  },

  render () {
    return (
      <Provider store={store}>
        <Router history={hashHistory} render={applyRouterMiddleware(useScroll())}>
          <Route path='/' component={UI}>
            <IndexRoute component={GettingStarted} />
            <Route path='/statuses/new' component={Compose} />
            <Route path='/statuses/home' component={HomeTimeline} />
            <Route path='/statuses/mentions' component={MentionsTimeline} />
            <Route path='/statuses/all' component={PublicTimeline} />
            <Route path='/statuses/:statusId' component={Status} />
            <Route path='/accounts/:accountId' component={Account}>
              <IndexRoute component={AccountTimeline} />
            </Route>
          </Route>
        </Router>
      </Provider>
    );
  }

});

export default Mastodon;
