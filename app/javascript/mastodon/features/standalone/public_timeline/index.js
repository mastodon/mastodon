import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../../ui/containers/status_list_container';
import { expandPublicTimeline } from '../../../actions/timelines';
import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import { defineMessages, injectIntl } from 'react-intl';
import { connectPublicStream } from '../../../actions/streaming';

const messages = defineMessages({
  title: { id: 'standalone.public_title', defaultMessage: 'A look inside...' },
});

@connect()
@injectIntl
export default class PublicTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(expandPublicTimeline());
    this.disconnect = dispatch(connectPublicStream());
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  handleLoadMore = maxId => {
    this.props.dispatch(expandPublicTimeline({ maxId }));
  }

  render () {
    const { intl } = this.props;

    return (
      <Column ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon='globe'
          title={intl.formatMessage(messages.title)}
          onClick={this.handleHeaderClick}
        />

        <StatusListContainer
          timelineId='public'
          onLoadMore={this.handleLoadMore}
          scrollKey='standalone_public_timeline'
          trackScroll={false}
        />
      </Column>
    );
  }

}
