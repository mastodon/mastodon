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
  Router,
  Route,
  hashHistory,
  IndexRoute
}                         from 'react-router';
import Account            from '../features/account';
import Status             from '../features/status';
import GettingStarted     from '../features/getting_started';
import PublicTimeline     from '../features/public_timeline';
import UI                 from '../features/ui';

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

    for (var timelineType in this.props.timelines) {
      if (this.props.timelines.hasOwnProperty(timelineType)) {
        store.dispatch(refreshTimelineSuccess(timelineType, JSON.parse(this.props.timelines[timelineType])));
      }
    }

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
        <Router history={hashHistory}>
          <Route path='/' component={UI}>
            <IndexRoute component={GettingStarted} />
            <Route path='/statuses/all' component={PublicTimeline} />
            <Route path='/statuses/:statusId' component={Status} />
            <Route path='/accounts/:accountId' component={Account} />
          </Route>
        </Router>
      </Provider>
    );
  }

});

export default Mastodon;
