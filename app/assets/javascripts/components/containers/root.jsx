import { Provider }                                                          from 'react-redux';
import configureStore                                                        from '../store/configureStore';
import Frontend                                                              from '../components/frontend';
import { setTimeline, updateTimeline, deleteFromTimelines, refreshTimeline } from '../actions/timelines';
import { setAccessToken }                                                    from '../actions/meta';
import PureRenderMixin                                                       from 'react-addons-pure-render-mixin';
import { Router, Route, createMemoryHistory }                                from 'react-router';
import AccountRoute                                                          from '../routes/account_route';
import StatusRoute                                                           from '../routes/status_route';

const store   = configureStore();
const history = createMemoryHistory();

const Root = React.createClass({

  propTypes: {
    token: React.PropTypes.string.isRequired,
    timelines: React.PropTypes.object
  },

  mixins: [PureRenderMixin],

  componentWillMount() {
    store.dispatch(setAccessToken(this.props.token));

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
        <Router history={history}>
          <Route path="/" component={Frontend}>
            <Route path="/accounts/:account_id" component={AccountRoute} />
            <Route path="/statuses/:status_id" component={StatusRoute} />
          </Route>
        </Router>
      </Provider>
    );
  }

});

export default Root;
