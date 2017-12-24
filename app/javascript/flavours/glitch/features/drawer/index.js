//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';
import spring from 'react-motion/lib/spring';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom';

//  Actions.
import { changeComposing } from 'flavours/glitch/actions/compose';
import { changeLocalSetting } from 'flavours/glitch/actions/local_settings';
import { openModal } from 'flavours/glitch/actions/modal';

//  Components.
import Icon from 'flavours/glitch/components/icon';
import Compose from 'flavours/glitch/features/compose';
import NavigationContainer from './containers/navigation_container';
import SearchContainer from './containers/search_container';
import SearchResultsContainer from './containers/search_results_container';

//  Utils.
import Motion from 'flavours/glitch/util/optional_motion';
import {
  assignHandlers,
  conditionalRender,
} from 'flavours/glitch/util/react_helpers';

//  Messages.
const messages = defineMessages({
  community: {
    defaultMessage: 'Local timeline',
    id: 'navigation_bar.community_timeline',
  },
  home_timeline: {
    defaultMessage: 'Home',
    id: 'tabs_bar.home',
  },
  logout: {
    defaultMessage: 'Logout',
    id: 'navigation_bar.logout',
  },
  notifications: {
    defaultMessage: 'Notifications',
    id: 'tabs_bar.notifications',
  },
  public: {
    defaultMessage: 'Federated timeline',
    id: 'navigation_bar.public_timeline',
  },
  settings: {
    defaultMessage: 'App settings',
    id: 'navigation_bar.app_settings',
  },
  start: {
    defaultMessage: 'Getting started',
    id: 'getting_started.heading',
  },
});

//  State mapping.
const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
});

//  Dispatch mapping.
const mapDispatchToProps = dispatch => ({
  onBlur () {
    dispatch(changeComposing(false));
  },
  onFocus () {
    dispatch(changeComposing(true));
  },
  onSettingsOpen () {
    dispatch(openModal('SETTINGS', {}));
  },
});

//  The component.
@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
export default function Drawer ({
  columns,
  intl,
  multiColumn,
  onBlur,
  onFocus,
  onSettingsOpen,
  showSearch,
}) {

  //  Only renders the component if the column isn't being shown.
  const renderForColumn = conditionalRender.bind(
    columnId => !columns.some(column => column.get('id') === columnId)
  );

  //  The result.
  return (
    <div className='drawer'>
      {multiColumn ? (
        <nav className='drawer__header'>
          <Link
            aria-label={intl.formatMessage(messages.start)}
            className='drawer__tab'
            title={intl.formatMessage(messages.start)}
            to='/getting-started'
          ><Icon icon='asterisk' /></Link>
          {renderForColumn('HOME', (
            <Link
              aria-label={intl.formatMessage(messages.home_timeline)}
              className='drawer__tab'
              title={intl.formatMessage(messages.home_timeline)}
              to='/timelines/home'
            ><Icon icon='home' /></Link>
          ))}
          {renderForColumn('NOTIFICATIONS', (
            <Link
              aria-label={intl.formatMessage(messages.notifications)}
              className='drawer__tab'
              title={intl.formatMessage(messages.notifications)}
              to='/notifications'
            ><Icon icon='bell' /></Link>
          ))}
          {renderForColumn('COMMUNITY', (
            <Link
              aria-label={intl.formatMessage(messages.community)}
              className='drawer__tab'
              title={intl.formatMessage(messages.community)}
              to='/timelines/public/local'
            ><Icon icon='users' /></Link>
          ))}
          {renderForColumn('PUBLIC', (
            <Link
              aria-label={intl.formatMessage(messages.public)}
              className='drawer__tab'
              title={intl.formatMessage(messages.public)}
              to='/timelines/public'
            ><Icon icon='globe' /></Link>
          ))}
          <a
            aria-label={intl.formatMessage(messages.settings)}
            className='drawer__tab'
            onClick={settings}
            role='button'
            title={intl.formatMessage(messages.settings)}
            tabIndex='0'
          ><Icon icon='cogs' /></a>
          <a
            aria-label={intl.formatMessage(messages.logout)}
            className='drawer__tab'
            data-method='delete'
            href='/auth/sign_out'
            title={intl.formatMessage(messages.logout)}
          ><Icon icon='sign-out' /></a>
        </nav>
      ) : null}
      <SearchContainer />
      <div className='drawer__pager'>
        <div
          className='drawer__inner scrollable optionally-scrollable'
          onFocus={focus}
        >
          <NavigationContainer onClose={blur} />
          <Compose />
        </div>
        <Motion
          defaultStyle={{ x: -100 }}
          style={{
            x: spring(showSearch ? 0 : -100, {
              stiffness: 210,
              damping: 20,
            })
          }}
        >
          {({ x }) => (
            <div
              className='drawer__inner darker scrollable optionally-scrollable'
              style={{
                transform: `translateX(${x}%)`,
                visibility: x === -100 ? 'hidden' : 'visible'
              }}
            ><SearchResultsContainer /></div>
          )}
        </Motion>
      </div>
    </div>
  );
}

//  Props.
Drawer.propTypes = {
  dispatch: PropTypes.func.isRequired,
  columns: ImmutablePropTypes.list.isRequired,
  multiColumn: PropTypes.bool,
  showSearch: PropTypes.bool,
  intl: PropTypes.object.isRequired,
};
