import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines
} from '../../actions/timelines';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import createStream from '../../stream';

const mapStateToProps = state => ({
  accessToken: state.getIn(['meta', 'access_token'])
});

const HashtagTimeline = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    accessToken: React.PropTypes.string.isRequired
  },

  mixins: [PureRenderMixin],

  _subscribe (dispatch, id) {
    const { accessToken } = this.props;

    this.subscription = createStream(accessToken, `hashtag&tag=${id}`, {

      received (data) {
        switch(data.event) {
        case 'update':
          dispatch(updateTimeline('tag', JSON.parse(data.payload)));
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        }
      }

    });
  },

  _unsubscribe () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.close();
      this.subscription = null;
    }
  },

  componentDidMount () {
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
        <ColumnBackButtonSlim />
        <StatusListContainer type='tag' id={id} />
      </Column>
    );
  },

});

export default connect(mapStateToProps)(HashtagTimeline);
