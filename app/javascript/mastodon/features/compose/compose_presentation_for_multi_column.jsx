import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages } from 'react-intl';
import { Link } from 'react-router-dom';
import SearchContainer from './containers/search_container';
import Motion from '../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import SearchResultsContainer from './containers/search_results_container';
import elephantUIPlane from '../../../images/elephant_ui_plane.svg';
import { mascot } from '../../initial_state';
import Icon from 'mastodon/components/icon';
import { isMobile } from '../../is_mobile';

const hasColumn = (columns, id) => columns.some(column => column.get('id') === id);

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new post' },
});

const ComposePresentationForMultiColumn = ({ showSearch, intl, columns, onClickLogout, onFocus, onBlur }) => {
  return (
    <div className='drawer' role='region' aria-label={intl.formatMessage(messages.compose)}>
      <nav className='drawer__header'>
        <Link to='/getting-started' className='drawer__tab' title={intl.formatMessage(messages.start)} aria-label={intl.formatMessage(messages.start)}><Icon id='bars' fixedWidth /></Link>
        {!hasColumn(columns, 'HOME') && (
          <Link to='/home' className='drawer__tab' title={intl.formatMessage(messages.home_timeline)} aria-label={intl.formatMessage(messages.home_timeline)}><Icon id='home' fixedWidth /></Link>
        )}
        {!hasColumn(columns, 'NOTIFICATIONS') && (
          <Link to='/notifications' className='drawer__tab' title={intl.formatMessage(messages.notifications)} aria-label={intl.formatMessage(messages.notifications)}><Icon id='bell' fixedWidth /></Link>
        )}
        {!hasColumn(columns, 'COMMUNITY') && (
          <Link to='/public/local' className='drawer__tab' title={intl.formatMessage(messages.community)} aria-label={intl.formatMessage(messages.community)}><Icon id='users' fixedWidth /></Link>
        )}
        {!hasColumn(columns, 'PUBLIC') && (
          <Link to='/public' className='drawer__tab' title={intl.formatMessage(messages.public)} aria-label={intl.formatMessage(messages.public)}><Icon id='globe' fixedWidth /></Link>
        )}
        <a href='/settings/preferences' className='drawer__tab' title={intl.formatMessage(messages.preferences)} aria-label={intl.formatMessage(messages.preferences)}><Icon id='cog' fixedWidth /></a>
        <a href='/auth/sign_out' className='drawer__tab' title={intl.formatMessage(messages.logout)} aria-label={intl.formatMessage(messages.logout)} onClick={onClickLogout}><Icon id='sign-out' fixedWidth /></a>
      </nav>

      <SearchContainer />

      <div className='drawer__pager'>
        <div className='drawer__inner' onFocus={onFocus}>
          <NavigationContainer onClose={onBlur} />
          <ComposeFormContainer autoFocus={!isMobile(window.innerWidth)} />

          <div className='drawer__inner__mastodon'>
            <img alt='' draggable='false' src={mascot || elephantUIPlane} />
          </div>
        </div>

        <Motion defaultStyle={{ x: -100 }} style={{ x: spring(showSearch ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
          {({ x }) => (
            <div className='drawer__inner darker' style={{ transform: `translateX(${x}%)`, visibility: x === -100 ? 'hidden' : 'visible' }}>
              <SearchResultsContainer />
            </div>
          )}
        </Motion>
      </div>
    </div>
  );
};

ComposePresentationForMultiColumn.propTypes = {
  onFocus: PropTypes.func.isRequired,
  onBlur: PropTypes.func.isRequired,
  onClickLogout: PropTypes.func.isRequired,
  columns: ImmutablePropTypes.list.isRequired,
  showSearch: PropTypes.bool,
  intl: PropTypes.object.isRequired,
};

export default ComposePresentationForMultiColumn;
