import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import spring from 'react-motion/lib/spring';

import { openModal } from 'mastodon/actions/modal';
import Column from 'mastodon/components/column';
import { Icon }  from 'mastodon/components/icon';
import { logOut } from 'mastodon/utils/log_out';

import elephantUIPlane from '../../../images/elephant_ui_plane.svg';
import { changeComposing, mountCompose, unmountCompose } from '../../actions/compose';
import { mascot } from '../../initial_state';
import { isMobile } from '../../is_mobile';
import Motion from '../ui/util/optional_motion';

import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import SearchContainer from './containers/search_container';
import SearchResultsContainer from './containers/search_results_container';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  compose: { id: 'navigation_bar.compose', defaultMessage: 'Compose new post' },
  logoutMessage: { id: 'confirmations.logout.message', defaultMessage: 'Are you sure you want to log out?' },
  logoutConfirm: { id: 'confirmations.logout.confirm', defaultMessage: 'Log out' },
});

const mapStateToProps = (state, ownProps) => ({
  columns: state.getIn(['settings', 'columns']),
  showSearch: ownProps.multiColumn ? state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']) : false,
});

class Compose extends PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(mountCompose());
  }

  componentWillUnmount () {
    const { dispatch } = this.props;
    dispatch(unmountCompose());
  }

  handleLogoutClick = e => {
    const { dispatch, intl } = this.props;

    e.preventDefault();
    e.stopPropagation();

    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.logoutMessage),
        confirm: intl.formatMessage(messages.logoutConfirm),
        closeWhenConfirm: false,
        onConfirm: () => logOut(),
      },
    }));

    return false;
  };

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  };

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  };

  render () {
    const { multiColumn, showSearch, intl } = this.props;

    if (multiColumn) {
      const { columns } = this.props;

      return (
        <div className='drawer' role='region' aria-label={intl.formatMessage(messages.compose)}>
          <nav className='drawer__header'>
            <Link to='/getting-started' className='drawer__tab' title={intl.formatMessage(messages.start)} aria-label={intl.formatMessage(messages.start)}><Icon id='bars' fixedWidth /></Link>
            {!columns.some(column => column.get('id') === 'HOME') && (
              <Link to='/home' className='drawer__tab' title={intl.formatMessage(messages.home_timeline)} aria-label={intl.formatMessage(messages.home_timeline)}><Icon id='home' fixedWidth /></Link>
            )}
            {!columns.some(column => column.get('id') === 'NOTIFICATIONS') && (
              <Link to='/notifications' className='drawer__tab' title={intl.formatMessage(messages.notifications)} aria-label={intl.formatMessage(messages.notifications)}><Icon id='bell' fixedWidth /></Link>
            )}
            {!columns.some(column => column.get('id') === 'COMMUNITY') && (
              <Link to='/public/local' className='drawer__tab' title={intl.formatMessage(messages.community)} aria-label={intl.formatMessage(messages.community)}><Icon id='users' fixedWidth /></Link>
            )}
            {!columns.some(column => column.get('id') === 'PUBLIC') && (
              <Link to='/public' className='drawer__tab' title={intl.formatMessage(messages.public)} aria-label={intl.formatMessage(messages.public)}><Icon id='globe' fixedWidth /></Link>
            )}
            <a href='/settings/preferences' className='drawer__tab' title={intl.formatMessage(messages.preferences)} aria-label={intl.formatMessage(messages.preferences)}><Icon id='cog' fixedWidth /></a>
            <a href='/auth/sign_out' className='drawer__tab' title={intl.formatMessage(messages.logout)} aria-label={intl.formatMessage(messages.logout)} onClick={this.handleLogoutClick}><Icon id='sign-out' fixedWidth /></a>
          </nav>

          {multiColumn && <SearchContainer /> }

          <div className='drawer__pager'>
            <div className='drawer__inner' onFocus={this.onFocus}>
              <NavigationContainer onClose={this.onBlur} />

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
    }

    return (
      <Column onFocus={this.onFocus}>
        <NavigationContainer onClose={this.onBlur} />
        <ComposeFormContainer />

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Compose));
