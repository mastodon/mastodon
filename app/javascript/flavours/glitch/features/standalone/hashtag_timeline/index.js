import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from 'flavours/glitch/features/ui/containers/status_list_container';
import { expandHashtagTimeline } from 'flavours/glitch/actions/timelines';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import { connectHashtagStream } from 'flavours/glitch/actions/streaming';

@connect()
export default class HashtagTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    hashtag: PropTypes.string.isRequired,
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  componentDidMount () {
    const { dispatch, hashtag } = this.props;

    dispatch(expandHashtagTimeline(hashtag));
    this.disconnect = dispatch(connectHashtagStream(hashtag));
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  handleLoadMore = maxId => {
    this.props.dispatch(expandHashtagTimeline(this.props.hashtag, { maxId }));
  }

  shouldUpdateScroll = (prevRouterProps, { location }) => {
    return !(location.state && location.state.mastodonModalOpen)
  }

  render () {
    const { hashtag } = this.props;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='hashtag'
          title={hashtag}
          onClick={this.handleHeaderClick}
        />

        <StatusListContainer
          trackScroll={false}
          scrollKey='standalone_hashtag_timeline'
          shouldUpdateScroll={this.shouldUpdateScroll}
          timelineId={`hashtag:${hashtag}`}
          onLoadMore={this.handleLoadMore}
        />
      </Column>
    );
  }

}
