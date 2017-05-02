import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines
} from '../../actions/timelines';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import { FormattedMessage } from 'react-intl';
import createStream from '../../stream';

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'tag', 'unread']) > 0,
  streamingAPIBaseURL: state.getIn(['meta', 'streaming_api_base_url']),
  accessToken: state.getIn(['meta', 'access_token'])
});

class HashtagTimeline extends React.PureComponent {

  _subscribe (dispatch, id) {
    const { streamingAPIBaseURL, accessToken } = this.props;

    this.subscription = createStream(streamingAPIBaseURL, accessToken, `hashtag&tag=${id}`, {

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
  }

  _unsubscribe () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.close();
      this.subscription = null;
    }
  }

  componentDidMount () {
    const { dispatch } = this.props;
    const { id } = this.props.params;

    dispatch(refreshTimeline('tag', id));
    this._subscribe(dispatch, id);
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.id !== this.props.params.id) {
      this.props.dispatch(refreshTimeline('tag', nextProps.params.id));
      this._unsubscribe();
      this._subscribe(this.props.dispatch, nextProps.params.id);
    }
  }

  componentWillUnmount () {
    this._unsubscribe();
  }

  render () {
    const { id, hasUnread } = this.props.params;

    return (
      <Column icon='hashtag' active={hasUnread} heading={id}>
        <ColumnBackButtonSlim />
        <StatusListContainer scrollKey='hashtag_timeline' type='tag' id={id} emptyMessage={<FormattedMessage id='empty_column.hashtag' defaultMessage='There is nothing in this hashtag yet.' />} />
      </Column>
    );
  }

}

HashtagTimeline.propTypes = {
  params: PropTypes.object.isRequired,
  dispatch: PropTypes.func.isRequired,
  streamingAPIBaseURL: PropTypes.string.isRequired,
  accessToken: PropTypes.string.isRequired,
  hasUnread: PropTypes.bool
};

export default connect(mapStateToProps)(HashtagTimeline);
