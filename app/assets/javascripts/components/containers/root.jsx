import { Provider }                                                          from 'react-redux';
import configureStore                                                        from '../store/configureStore';
import Frontend                                                              from '../components/frontend';
import { setTimeline, updateTimeline, deleteFromTimelines, refreshTimeline } from '../actions/timelines';
import { setAccessToken }                                                    from '../actions/meta';
import { setAccountSelf }                                                    from '../actions/accounts';
import PureRenderMixin                                                       from 'react-addons-pure-render-mixin';
import { Router, Route, hashHistory }                                        from 'react-router';

const store = configureStore();

const Root = React.createClass({

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
          <Route path='/' component={Frontend}>
            <Route path='/settings' component={null} />
            <Route path='/subscriptions' component={null} />
            <Route path='/statuses/:statusId' component={null} />
            <Route path='/accounts/:accountId' component={null} />
          </Route>
        </Router>
      </Provider>
    );
  }

});

export default Root;
