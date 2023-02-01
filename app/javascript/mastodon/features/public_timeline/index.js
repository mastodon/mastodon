import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandPublicTimeline } from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import ColumnSettingsContainer from './containers/column_settings_container';
import { connectPublicStream } from '../../actions/streaming';
import { Helmet } from 'react-helmet';
import DismissableBanner from 'mastodon/components/dismissable_banner';

const messages = defineMessages({
  title: { id: 'column.public', defaultMessage: 'Federated timeline' },
});

const mapStateToProps = (state, { columnId }) => {
  const uuid = columnId;
  const columns = state.getIn(['settings', 'columns']);
  const index = columns.findIndex(c => c.get('uuid') === uuid);
  const onlyMedia = (columnId && index >= 0) ? columns.get(index).getIn(['params', 'other', 'onlyMedia']) : state.getIn(['settings', 'public', 'other', 'onlyMedia']);
  const onlyRemote = (columnId && index >= 0) ? columns.get(index).getIn(['params', 'other', 'onlyRemote']) : state.getIn(['settings', 'public', 'other', 'onlyRemote']);
  const onlyLocal = (columnId && index >= 0) ? columns.get(index).getIn(['params', 'other', 'onlyLocal']) : state.getIn(['settings', 'public', 'other', 'onlyLocal']);
  const timelineState = state.getIn(['timelines', `public${onlyMedia ? ':media' : ''}`]);

  return {
    hasUnread: !!timelineState && timelineState.get('unread') > 0,
    onlyMedia,
    onlyRemote,
    onlyLocal,
  };
};

export default @connect(mapStateToProps)
@injectIntl
class PublicTimeline extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
    identity: PropTypes.object,
  };

  static defaultProps = {
    onlyMedia: false,
    onlyLocal: false,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasUnread: PropTypes.bool,
    onlyMedia: PropTypes.bool,
    onlyRemote: PropTypes.bool,
    onlyLocal: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch, onlyMedia, onlyRemote, onlyLocal } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn(onlyRemote ? 'REMOTE' : 'PUBLIC', { other: { onlyMedia, onlyRemote, onlyLocal } }));
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  componentDidMount () {
    const { dispatch, onlyMedia, onlyRemote, onlyLocal } = this.props;
    const { signedIn } = this.context.identity;

    dispatch(expandPublicTimeline({ onlyMedia, onlyRemote, onlyLocal }));

    if (signedIn) {
      this.disconnect = dispatch(connectPublicStream({ onlyMedia, onlyRemote, onlyLocal }));
    }
  }

  componentDidUpdate (prevProps) {
    const { signedIn } = this.context.identity;

    if (prevProps.onlyMedia !== this.props.onlyMedia || prevProps.onlyRemote !== this.props.onlyRemote, prevProps.onlyLocal !== this.props.onlyLocal) {
      const { dispatch, onlyMedia, onlyRemote, onlyLocal } = this.props;

      if (this.disconnect) {
        this.disconnect();
      }

      dispatch(expandPublicTimeline({ onlyMedia, onlyRemote, onlyLocal }));

      if (signedIn) {
        this.disconnect = dispatch(connectPublicStream({ onlyMedia, onlyRemote, onlyLocal }));
      }
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  };

  handleLoadMore = maxId => {
    const { dispatch, onlyMedia, onlyRemote, onlyLocal } = this.props;

    dispatch(expandPublicTimeline({ maxId, onlyMedia, onlyRemote, onlyLocal }));
  }

  render () {
    const { intl, columnId, hasUnread, multiColumn, onlyMedia, onlyRemote, onlyLocal } = this.props;
    const pinned = !!columnId;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon='globe'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer columnId={columnId} />
        </ColumnHeader>

        <DismissableBanner id='public_timeline'>
          <FormattedMessage id='dismissable_banner.public_timeline' defaultMessage='These are the most recent public posts from people on this and other servers of the decentralized network that this server knows about.' />
        </DismissableBanner>

        <StatusListContainer
          timelineId={`public${onlyRemote ? ':remote' : ''}${onlyMedia ? ':media' : ''}${onlyLocal ? ':local' : ''}`}
          onLoadMore={this.handleLoadMore}
          trackScroll={!pinned}
          scrollKey={`public_timeline-${columnId}`}
          emptyMessage={<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here! Write something publicly, or manually follow users from other servers to fill it up' />}
          bindToDocument={!multiColumn}
        />

        <Helmet>
          <title>{intl.formatMessage(messages.title)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}
