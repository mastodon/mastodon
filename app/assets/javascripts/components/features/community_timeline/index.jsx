import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines,
  connectTimeline,
  disconnectTimeline
} from '../../actions/timelines';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import createStream from '../../stream';

const messages = defineMessages({
  title: { id: 'column.community', defaultMessage: 'Local timeline' }
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'community', 'unread']) > 0,
  streamingAPIBaseURL: state.getIn(['meta', 'streaming_api_base_url']),
  accessToken: state.getIn(['meta', 'access_token'])
});

let subscription;

class CommunityTimeline extends React.PureComponent {

  componentDidMount () {
    const { dispatch, streamingAPIBaseURL, accessToken } = this.props;

    dispatch(refreshTimeline('community'));

    if (typeof subscription !== 'undefined') {
      return;
    }

    subscription = createStream(streamingAPIBaseURL, accessToken, 'public:local', {

      connected () {
        dispatch(connectTimeline('community'));
      },

      reconnected () {
        dispatch(connectTimeline('community'));
      },

      disconnected () {
        dispatch(disconnectTimeline('community'));
      },

      received (data) {
        switch(data.event) {
        case 'update':
          dispatch(updateTimeline('community', JSON.parse(data.payload)));
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        }
      }

    });
  }

  componentWillUnmount () {
    // if (typeof subscription !== 'undefined') {
    //   subscription.close();
    //   subscription = null;
    // }
  }

  render () {
    const { intl, hasUnread } = this.props;

    return (
      <Column icon='users' active={hasUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />
        <StatusListContainer {...this.props} scrollKey='community_timeline' type='community' emptyMessage={<FormattedMessage id='empty_column.community' defaultMessage='The local timeline is empty. Write something publicly to get the ball rolling!' />} />
      </Column>
    );
  }

}

CommunityTimeline.propTypes = {
  dispatch: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired,
  streamingAPIBaseURL: PropTypes.string.isRequired,
  accessToken: PropTypes.string.isRequired,
  hasUnread: PropTypes.bool
};

export default connect(mapStateToProps)(injectIntl(CommunityTimeline));
