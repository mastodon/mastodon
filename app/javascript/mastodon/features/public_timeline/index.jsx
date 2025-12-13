import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { connect } from 'react-redux';

import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import { DismissableBanner } from 'mastodon/components/dismissable_banner';
import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import { domain, localLiveFeedAccess, remoteLiveFeedAccess } from 'mastodon/initial_state';
import { canViewFeed } from 'mastodon/permissions';

import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { connectPublicStream } from '../../actions/streaming';
import { expandPublicTimeline } from '../../actions/timelines';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import StatusListContainer from '../ui/containers/status_list_container';

import ColumnSettingsContainer from './containers/column_settings_container';

const messages = defineMessages({
  title: { id: 'column.public', defaultMessage: 'Federated timeline' },
});

const mapStateToProps = (state, { columnId }) => {
  const uuid = columnId;
  const columns = state.getIn(['settings', 'columns']);
  const index = columns.findIndex(c => c.get('uuid') === uuid);
  const onlyMedia = (columnId && index >= 0) ? columns.get(index).getIn(['params', 'other', 'onlyMedia']) : state.getIn(['settings', 'public', 'other', 'onlyMedia']);
  const onlyRemote = (columnId && index >= 0) ? columns.get(index).getIn(['params', 'other', 'onlyRemote']) : state.getIn(['settings', 'public', 'other', 'onlyRemote']);
  const timelineState = state.getIn(['timelines', `public${onlyRemote ? ':remote' : ''}${onlyMedia ? ':media' : ''}`]);

  return {
    hasUnread: !!timelineState && timelineState.get('unread') > 0,
    onlyMedia,
    onlyRemote,
  };
};

class PublicTimeline extends PureComponent {
  static defaultProps = {
    onlyMedia: false,
  };

  static propTypes = {
    identity: identityContextPropShape,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasUnread: PropTypes.bool,
    onlyMedia: PropTypes.bool,
    onlyRemote: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch, onlyMedia, onlyRemote } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn(onlyRemote ? 'REMOTE' : 'PUBLIC', { other: { onlyMedia, onlyRemote } }));
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
    const { dispatch, onlyMedia, onlyRemote } = this.props;
    const { signedIn } = this.props.identity;

    dispatch(expandPublicTimeline({ onlyMedia, onlyRemote }));

    if (signedIn) {
      this.disconnect = dispatch(connectPublicStream({ onlyMedia, onlyRemote }));
    }
  }

  componentDidUpdate (prevProps) {
    const { signedIn } = this.props.identity;

    if (prevProps.onlyMedia !== this.props.onlyMedia || prevProps.onlyRemote !== this.props.onlyRemote) {
      const { dispatch, onlyMedia, onlyRemote } = this.props;

      if (this.disconnect) {
        this.disconnect();
      }

      dispatch(expandPublicTimeline({ onlyMedia, onlyRemote }));

      if (signedIn) {
        this.disconnect = dispatch(connectPublicStream({ onlyMedia, onlyRemote }));
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
    const { dispatch, onlyMedia, onlyRemote } = this.props;

    dispatch(expandPublicTimeline({ maxId, onlyMedia, onlyRemote }));
  };

  render () {
    const { intl, columnId, hasUnread, multiColumn, onlyMedia, onlyRemote } = this.props;
    const { signedIn, permissions } = this.props.identity;
    const pinned = !!columnId;

    const emptyMessage = (canViewFeed(signedIn, permissions, localLiveFeedAccess) || canViewFeed(signedIn, permissions, remoteLiveFeedAccess)) ? (
      <FormattedMessage
        id='empty_column.public'
        defaultMessage='There is nothing here! Write something publicly, or manually follow users from other servers to fill it up'
      />
    ) : (
      <FormattedMessage
        id='empty_column.disabled_feed'
        defaultMessage='This feed has been disabled by your server administrators.'
      />
    );

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon='globe'
          iconComponent={PublicIcon}
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

        <StatusListContainer
          prepend={<DismissableBanner id='public_timeline'><FormattedMessage id='dismissable_banner.public_timeline' defaultMessage='These are the most recent public posts from people on the fediverse that people on {domain} follow.' values={{ domain }} /></DismissableBanner>}
          timelineId={`public${onlyRemote ? ':remote' : ''}${onlyMedia ? ':media' : ''}`}
          onLoadMore={this.handleLoadMore}
          trackScroll={!pinned}
          scrollKey={`public_timeline-${columnId}`}
          emptyMessage={emptyMessage}
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

export default connect(mapStateToProps)(withIdentity(injectIntl(PublicTimeline)));
