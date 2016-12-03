import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines
} from '../../actions/timelines';

const HashtagTimeline = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  _subscribe (dispatch, id) {
    if (typeof App !== 'undefined') {
      this.subscription = App.cable.subscriptions.create({
        channel: 'HashtagChannel',
        tag: id
      }, {

        received (data) {
          switch(data.type) {
            case 'update':
              return dispatch(updateTimeline('tag', JSON.parse(data.message)));
            case 'delete':
              return dispatch(deleteFromTimelines(data.id));
          }
        }

      });
    }
  },

  _unsubscribe () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.unsubscribe();
    }
  },

  componentWillMount () {
    const { dispatch } = this.props;
    const { id } = this.props.params;

    dispatch(refreshTimeline('tag', id));
    this._subscribe(dispatch, id);
  },

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.id !== this.props.params.id) {
      this.props.dispatch(refreshTimeline('tag', nextProps.params.id));
      this._unsubscribe();
      this._subscribe(this.props.dispatch, nextProps.params.id);
    }
  },

  componentWillUnmount () {
    this._unsubscribe();
  },

  render () {
    const { id } = this.props.params;

    return (
      <Column icon='hashtag' heading={id}>
        <StatusListContainer type='tag' id={id} />
      </Column>
    );
  },

});

export default connect()(HashtagTimeline);
