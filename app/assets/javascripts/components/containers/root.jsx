import { Provider }               from 'react-redux';
import configureStore             from '../store/configureStore';
import Frontend                   from '../components/frontend';
import { setTimeline, addStatus } from '../actions/statuses';

const store = configureStore();

const Root = React.createClass({

  componentWillMount() {
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
          return store.dispatch(addStatus(data.timeline, JSON.parse(data.message)));
        }
      });
    }
  },

  render() {
    return (
      <Provider store={store}>
        <Frontend />
      </Provider>
    );
  }

});

export default Root;
