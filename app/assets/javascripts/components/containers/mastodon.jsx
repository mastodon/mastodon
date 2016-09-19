import { Provider }                                                          from 'react-redux';
import configureStore                                                        from '../store/configureStore';
import { setTimeline, updateTimeline, deleteFromTimelines, refreshTimeline } from '../actions/timelines';
import { setAccessToken }                                                    from '../actions/meta';
import { setAccountSelf }                                                    from '../actions/accounts';
import PureRenderMixin                                                       from 'react-addons-pure-render-mixin';
import { Router, Route, hashHistory }                                        from 'react-router';
import Account                                                               from '../features/account';
import Settings                                                              from '../features/settings';
import Status                                                                from '../features/status';
import Subscriptions                                                         from '../features/subscriptions';
import UI                                                                    from '../features/ui';

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
        store.dispatch(setTimeline(timelineType, JSON.parse(this.props.timelines[timelineType])));
      }
    }

    if (typeof App !== 'undefined') {
      App.timeline = App.cable.subscriptions.create("TimelineChannel", {
        connected: function() {},

        disconnected: function() {},

        received: function(data) {
          switch(data.type) {
            case 'update':
              return store.dispatch(updateTimeline(data.timeline, JSON.parse(data.message)));
            case 'delete':
              return store.dispatch(deleteFromTimelines(data.id));
            case 'merge':
            case 'unmerge':
              return store.dispatch(refreshTimeline('home'));
          }
        }
      });
    }
  },

  render () {
    return (
      <Provider store={store}>
        <Router history={hashHistory}>
          <Route path='/' component={UI}>
            <Route path='/settings' component={Settings} />
            <Route path='/subscriptions' component={Subscriptions} />
            <Route path='/statuses/:statusId' component={Status} />
            <Route path='/accounts/:accountId' component={Account} />
          </Route>
        </Router>
      </Provider>
    );
  }

});

export default Mastodon;
