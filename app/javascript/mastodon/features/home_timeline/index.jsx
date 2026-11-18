import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { connect } from 'react-redux';

import { Column } from '@/mastodon/components/column';
import { injectIntl } from '@/mastodon/components/intl';
import { NotSignedInIndicator } from 'mastodon/components/not_signed_in_indicator';
import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import { withBreakpoint } from 'mastodon/features/ui/hooks/useBreakpoint';

import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { expandHomeTimeline } from '../../actions/timelines';
import StatusListContainer from '../ui/containers/status_list_container';

import { CriticalUpdateBanner } from './components/critical_update_banner';
import { AnnualReportTimeline } from '../annual_report/timeline';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { HomeColumnSettings } from './components/column_settings_redesign';
import { MultiColumnMenuItems } from '@/mastodon/components/column_header/multicolumn_settings';

const messages = defineMessages({
  title: { id: 'column.home', defaultMessage: 'Home' },
  show_announcements: { id: 'home.show_announcements', defaultMessage: 'Show announcements' },
  hide_announcements: { id: 'home.hide_announcements', defaultMessage: 'Hide announcements' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'home', 'unread']) > 0,
  isPartial: state.getIn(['timelines', 'home', 'isPartial']),
  hasAnnouncements: !state.getIn(['announcements', 'items']).isEmpty(),
  unreadAnnouncements: state.getIn(['announcements', 'items']).count(item => !item.get('read')),
  showAnnouncements: state.getIn(['announcements', 'show']),
});

class HomeTimeline extends PureComponent {
  static propTypes = {
    identity: identityContextPropShape,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    isPartial: PropTypes.bool,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasAnnouncements: PropTypes.bool,
    unreadAnnouncements: PropTypes.number,
    showAnnouncements: PropTypes.bool,
    matchesBreakpoint: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('HOME', {}));
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleLoadMore = maxId => {
    this.props.dispatch(expandHomeTimeline({ maxId }));
  };

  componentDidMount () {
    this._checkIfReloadNeeded(false, this.props.isPartial);
  }

  componentDidUpdate (prevProps) {
    this._checkIfReloadNeeded(prevProps.isPartial, this.props.isPartial);
  }

  componentWillUnmount () {
    this._stopPolling();
  }

  _checkIfReloadNeeded (wasPartial, isPartial) {
    const { dispatch } = this.props;

    if (wasPartial === isPartial) {
      return;
    } else if (!wasPartial && isPartial) {
      this.polling = setInterval(() => {
        dispatch(expandHomeTimeline());
      }, 3000);
    } else if (wasPartial && !isPartial) {
      this._stopPolling();
    }
  }

  _stopPolling () {
    if (this.polling) {
      clearInterval(this.polling);
      this.polling = null;
    }
  }

  render () {
    const { intl, hasUnread, columnId, multiColumn } = this.props;
    const pinned = !!columnId;
    const { signedIn } = this.props.identity;
    const banners = [
      <CriticalUpdateBanner key='critical-update-banner' />,
      <AnnualReportTimeline key='annual-report' />
    ];

    return (
      <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          title={intl.formatMessage(messages.title)}
          withBackButton={multiColumn && !pinned && 'auto'}
          withUnreadMarker={hasUnread}
          extraButtons={
            <HomeColumnSettings>
              {multiColumn &&
                <MultiColumnMenuItems
                  withDivider
                  pinned={pinned}
                  onPin={this.handlePin}
                  onMove={this.handleMove}
                />
              }
            </HomeColumnSettings>
          }
        />

        {signedIn ? (
          <StatusListContainer
            prepend={banners}
            alwaysPrepend
            trackScroll={!pinned}
            scrollKey={`home_timeline-${columnId}`}
            onLoadMore={this.handleLoadMore}
            timelineId='home'
            emptyMessage={<FormattedMessage id='empty_column.home' defaultMessage='Your home timeline is empty! Follow more people to fill it up.' />}
            bindToDocument={!multiColumn}
          />
        ) : <NotSignedInIndicator />}

        <Helmet>
          <title>{intl.formatMessage(messages.title)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(withBreakpoint(withIdentity(injectIntl(HomeTimeline))));
