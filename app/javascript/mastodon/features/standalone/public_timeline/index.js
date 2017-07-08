import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../../ui/containers/status_list_container';
import {
  refreshPublicTimeline,
  expandPublicTimeline,
  updateTimeline,
  deleteFromTimelines,
  connectTimeline,
  disconnectTimeline,
} from '../../../actions/timelines';
import createStream from '../../../stream';
import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  title: { id: 'standalone.public_title', defaultMessage: 'A look inside...' },
});

const mapStateToProps = state => ({
  streamingAPIBaseURL: state.getIn(['meta', 'streaming_api_base_url']),
});

@connect(mapStateToProps)
@injectIntl
export default class PublicTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    streamingAPIBaseURL: PropTypes.string.isRequired,
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  componentDidMount () {
    const { dispatch, streamingAPIBaseURL } = this.props;

    dispatch(refreshPublicTimeline());

    if (typeof this._subscription !== 'undefined') {
      return;
    }

    this._subscription = createStream(streamingAPIBaseURL, '', 'public', {

      connected () {
        dispatch(connectTimeline('public'));
      },

      reconnected () {
        dispatch(connectTimeline('public'));
      },

      disconnected () {
        dispatch(disconnectTimeline('public'));
      },

      received (data) {
        switch(data.event) {
        case 'update':
          dispatch(updateTimeline('public', JSON.parse(data.payload)));
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        }
      },

    });
  }

  componentWillUnmount () {
    if (typeof this._subscription !== 'undefined') {
      this._subscription.close();
      this._subscription = null;
    }
  }

  handleLoadMore = () => {
    this.props.dispatch(expandPublicTimeline());
  }

  render () {
    const { intl } = this.props;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='globe'
          title={intl.formatMessage(messages.title)}
          onClick={this.handleHeaderClick}
        />

        <StatusListContainer
          timelineId='public'
          loadMore={this.handleLoadMore}
          scrollKey='standalone_public_timeline'
          trackScroll={false}
        />
      </Column>
    );
  }

}
