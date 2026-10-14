import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from '@unhead/react/helmet';

import { connect } from 'react-redux';

import CampaignIcon from '@/material-icons/400-24px/campaign.svg?react';
import HomeIcon from '@/material-icons/400-24px/home-fill.svg?react';
import { Column } from '@/flavours/glitch/components/column';
import { ColumnHeader as LegacyColumnHeader } from '@/flavours/glitch/components/column/header';
import { injectIntl } from '@/flavours/glitch/components/intl';
import { SymbolLogo } from 'flavours/glitch/components/logo';
import { fetchAnnouncements, toggleShowAnnouncements } from 'flavours/glitch/actions/announcements';
import { IconWithBadge } from 'flavours/glitch/components/icon_with_badge';
import { NotSignedInIndicator } from 'flavours/glitch/components/not_signed_in_indicator';
import { identityContextPropShape, withIdentity } from 'flavours/glitch/identity_context';
import { withBreakpoint } from 'flavours/glitch/features/ui/hooks/useBreakpoint';
import { Announcements } from '@/flavours/glitch/features/announcements';

import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { expandHomeTimeline } from '../../actions/timelines';
import StatusListContainer from '../ui/containers/status_list_container';

import { ColumnSettings } from './components/column_settings';
import { CriticalUpdateBanner } from './components/critical_update_banner';
import { AnnualReportTimeline } from '../annual_report/timeline';
import { isRedesignEnabled } from '@/flavours/glitch/utils/environment';
import { ColumnHeader } from '@/flavours/glitch/components/column_header';
import { HomeColumnSettings } from './components/column_settings_redesign';
import { MultiColumnMenuItems } from '@/flavours/glitch/components/column_header/multicolumn_settings';

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
  regex: state.getIn(['settings', 'home', 'regex', 'body']),
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
    regex: PropTypes.string,
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
    if (!isRedesignEnabled()) {
      setTimeout(() => this.props.dispatch(fetchAnnouncements()), 700);
    }
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

  handleToggleAnnouncementsClick = (e) => {
    e.stopPropagation();
    this.props.dispatch(toggleShowAnnouncements());
  };

  render () {
    const { intl, hasUnread, columnId, multiColumn, hasAnnouncements, unreadAnnouncements, showAnnouncements, matchesBreakpoint } = this.props;
    const pinned = !!columnId;
    const { signedIn } = this.props.identity;
    const banners = [
      <CriticalUpdateBanner key='critical-update-banner' />,
      <AnnualReportTimeline key='annual-report' />
    ];

    let announcementsButton;

    if (hasAnnouncements) {
      announcementsButton = (
        <button
          type='button'
          className={classNames('column-header__button', { 'active': showAnnouncements })}
          title={intl.formatMessage(showAnnouncements ? messages.hide_announcements : messages.show_announcements)}
          aria-label={intl.formatMessage(showAnnouncements ? messages.hide_announcements : messages.show_announcements)}
          onClick={this.handleToggleAnnouncementsClick}
        >
          <IconWithBadge id='bullhorn' icon={CampaignIcon} count={unreadAnnouncements} />
        </button>
      );
    }

    return (
      <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.title)}>
        {isRedesignEnabled() ? (
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
        ) : (
          <LegacyColumnHeader
            icon='home'
            iconComponent={matchesBreakpoint ? SymbolLogo : HomeIcon}
            active={hasUnread}
            title={intl.formatMessage(messages.title)}
            onPin={this.handlePin}
            onMove={this.handleMove}
            pinned={pinned}
            multiColumn={multiColumn}
            extraButton={announcementsButton}
            appendContent={hasAnnouncements && showAnnouncements && <Announcements />}
            scrollTopOnClick
          >
            <ColumnSettings />
          </LegacyColumnHeader>
        )}

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
            regex={this.props.regex}
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
