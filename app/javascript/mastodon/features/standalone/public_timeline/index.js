import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../../ui/containers/status_list_container';
import {
  refreshPublicTimeline,
  expandPublicTimeline,
  refreshCommunityTimeline,
  expandCommunityTimeline,
} from '../../../actions/timelines';
import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  public: { id: 'standalone.public_title', defaultMessage: 'A look inside...' },
  community: { id: 'standalone.community_title', defaultMessage: 'A look inside...' },
});

@connect()
@injectIntl
export default class PublicTimeline extends React.PureComponent {

  constructor(props) {
    super(props);
    this.state = { isCommunity : true };
  }

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleHeaderClick = () => {
    this.setState({ isCommunity : !this.state.isCommunity });
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(refreshCommunityTimeline());
    dispatch(refreshPublicTimeline());

    this.polling = setInterval(() => {
      dispatch(refreshCommunityTimeline());
      dispatch(refreshPublicTimeline());
    }, 3000);
  }

  componentWillUnmount () {
    if (typeof this.polling !== 'undefined') {
      clearInterval(this.polling);
      this.polling = null;
    }
  }

  handleLoadMore = () => {
    if (this.state.isCommunity) {
      this.props.dispatch(expandCommunityTimeline());
    }else{
      this.props.dispatch(expandPublicTimeline());
    }
  }

  render () {
    const { intl } = this.props;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='globe'
          title={intl.formatMessage(this.state.isCommunity ? messages.community : messages.public)}
          onClick={this.handleHeaderClick}
        />

        <StatusListContainer
          timelineId={this.state.isCommunity ? 'community' : 'public'}
          loadMore={this.handleLoadMore}
          scrollKey='standalone_public_timeline'
          trackScroll={false}
        />
      </Column>
    );
  }

}
