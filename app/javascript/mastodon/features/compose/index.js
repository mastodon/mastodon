import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose } from '../../actions/compose';
import { Link } from 'react-router-dom';
import { injectIntl, defineMessages } from 'react-intl';
import SearchContainer from './containers/search_container';
import Motion from '../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import SearchResultsContainer from './containers/search_results_container';
import { changeComposing } from '../../actions/compose';
import { openModal } from 'mastodon/actions/modal';
import elephantUIPlane from '../../../images/elephant_ui_plane.svg';
import { mascot } from '../../initial_state';
import Icon from 'mastodon/components/icon';
import { logOut } from 'mastodon/utils/log_out';
import { isMobile } from '../../is_mobile';

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
  showSearch: ownProps.multiColumn ? state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']) : ownProps.isSearchPage,
});

let instanceMascot;
if (mascot) {
  instanceMascot = <img alt='' draggable='false' src={mascot} />;
} else {
  instanceMascot = <svg id='hometownlogo' width="2400" height="460" viewBox="0 0 2400 460" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet">
 <g>
  <g>
   <path d="m326.20431,287.85649l-302.73044,0c-10.28698,0 -19.10436,8.81738 -19.10436,19.10436s8.81738,19.10436 19.10436,19.10436l302.73044,0c10.28698,0 19.10436,-8.81738 19.10436,-19.10436s-8.81738,-19.10436 -19.10436,-19.10436z"/>
   <path d="m326.20431,351.04783l-302.73044,0c-10.28698,0 -19.10436,8.81738 -19.10436,19.10436s8.81738,19.10436 19.10436,19.10436l302.73044,0c10.28698,0 19.10436,-8.81738 19.10436,-19.10436s-8.81738,-19.10436 -19.10436,-19.10436z"/>
   <path d="m326.20431,415.70867l-302.73044,0c-10.28698,0 -19.10436,8.81738 -19.10436,19.10436s8.81738,19.10436 19.10436,19.10436l302.73044,0c10.28698,0 19.10436,-8.81738 19.10436,-19.10436s-8.81738,-19.10436 -19.10436,-19.10436z"/>
   <path d="m456.99565,287.85649c-10.28698,0 -19.10436,8.81738 -19.10436,19.10436l0,129.32173c0,10.28698 8.81738,19.10436 19.10436,19.10436s19.10436,-8.81738 19.10436,-19.10436l0,-129.32173c-1.46955,-11.75653 -10.28698,-19.10436 -19.10436,-19.10436z"/>
   <path d="m392.33476,287.85649c-10.28698,0 -19.10436,8.81738 -19.10436,19.10436l0,129.32173c0,10.28698 8.81738,19.10436 19.10436,19.10436s19.10436,-8.81738 19.10436,-19.10436l0,-129.32173c-1.46955,-11.75653 -8.81738,-19.10436 -19.10436,-19.10436z"/>
   <path d="m440.83045,205.56085c19.10436,-10.28698 29.39129,-36.73911 29.39129,-82.29564c0,-52.90436 -13.22609,-114.62609 -48.49564,-114.62609s-48.49564,61.72173 -48.49564,114.62609c0,45.55653 10.28698,72.00871 29.39129,82.29564l0,35.26955c0,10.28698 8.81738,19.10436 19.10436,19.10436s19.10436,-8.81738 19.10436,-19.10436l0,-35.26955l-0.00002,0zm-19.10436,-154.30436c5.87827,11.75653 11.75653,36.73911 11.75653,72.00871c0,36.73911 -7.34782,49.9652 -11.75653,49.9652s-11.75653,-13.22609 -11.75653,-49.9652c1.46955,-35.26955 7.34782,-60.25218 11.75653,-72.00871z"/>
   <path d="m342.36956,123.26521c0,-1.46955 -1.46955,-1.46955 -1.46955,-2.93911l-47.02609,-60.25218c-2.93911,-4.40871 -8.81738,-7.34782 -14.69564,-7.34782l-23.51307,0l0,-27.92173c0,-10.28698 -8.81738,-19.10436 -19.10436,-19.10436s-19.10436,8.81738 -19.10436,19.10436l0,29.39129l-57.31307,0l-16.1652,0l-76.41738,0c-5.87827,0 -10.28698,2.93911 -14.69564,7.34782l-47.02609,60.25218c0,1.46955 -1.46955,1.46955 -1.46955,2.93911c0,0 -1.46955,1.46955 -1.46955,1.46955c1.46955,1.46955 1.46955,4.40871 1.46955,5.87827l0,108.74782c0,10.28698 8.81738,19.10436 19.10436,19.10436l76.41738,0l108.74782,0l117.56525,0c10.28698,0 19.10436,-8.81738 19.10436,-19.10436l0,-108.74782c0,-2.93911 0,-4.40871 -1.46955,-5.87827c-1.46955,-1.46955 -1.46955,-1.46955 -1.46955,-2.93911l-0.00005,0l-0.00002,0zm-224.84351,99.93045l-76.41738,0l0,-72.00871l149.89564,0l0,72.00871l-73.47827,0l0.00001,0zm99.93045,-108.74782l-17.6348,-23.51307l70.53916,0l17.6348,23.51307l-70.53916,0zm-64.66089,-23.51307l17.6348,23.51307l-110.21738,0l17.6348,-23.51307l74.94782,0l-0.00005,0l0.00001,0zm74.94782,60.25218l80.82609,0l0,72.00871l-80.82609,0l0,-72.00871z"/>
  </g>
 </g>
</svg>;
}

export default @connect(mapStateToProps)
@injectIntl
class Compose extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    isSearchPage: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    const { isSearchPage } = this.props;

    if (!isSearchPage) {
      this.props.dispatch(mountCompose());
    }
  }

  componentWillUnmount () {
    const { isSearchPage } = this.props;

    if (!isSearchPage) {
      this.props.dispatch(unmountCompose());
    }
  }

  handleLogoutClick = e => {
    const { dispatch, intl } = this.props;

    e.preventDefault();
    e.stopPropagation();

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.logoutMessage),
      confirm: intl.formatMessage(messages.logoutConfirm),
      closeWhenConfirm: false,
      onConfirm: () => logOut(),
    }));

    return false;
  }

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  }

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  }

  render () {
    const { multiColumn, showSearch, isSearchPage, intl } = this.props;

    let header = '';

    if (multiColumn) {
      const { columns } = this.props;
      header = (
        <nav className='drawer__header'>
          <Link to='/getting-started' className='drawer__tab' title={intl.formatMessage(messages.start)} aria-label={intl.formatMessage(messages.start)}><Icon id='bars' fixedWidth /></Link>
          {!columns.some(column => column.get('id') === 'HOME') && (
            <Link to='/timelines/home' className='drawer__tab' title={intl.formatMessage(messages.home_timeline)} aria-label={intl.formatMessage(messages.home_timeline)}><Icon id='home' fixedWidth /></Link>
          )}
          {!columns.some(column => column.get('id') === 'NOTIFICATIONS') && (
            <Link to='/notifications' className='drawer__tab' title={intl.formatMessage(messages.notifications)} aria-label={intl.formatMessage(messages.notifications)}><Icon id='bell' fixedWidth /></Link>
          )}
          {!columns.some(column => column.get('id') === 'COMMUNITY') && (
            <Link to='/timelines/public/local' className='drawer__tab' title={intl.formatMessage(messages.community)} aria-label={intl.formatMessage(messages.community)}><Icon id='users' fixedWidth /></Link>
          )}
          {!columns.some(column => column.get('id') === 'PUBLIC') && (
            <Link to='/timelines/public' className='drawer__tab' title={intl.formatMessage(messages.public)} aria-label={intl.formatMessage(messages.public)}><Icon id='globe' fixedWidth /></Link>
          )}
          <a href='/settings/preferences' className='drawer__tab' title={intl.formatMessage(messages.preferences)} aria-label={intl.formatMessage(messages.preferences)}><Icon id='cog' fixedWidth /></a>
          <a href='/auth/sign_out' className='drawer__tab' title={intl.formatMessage(messages.logout)} aria-label={intl.formatMessage(messages.logout)} onClick={this.handleLogoutClick}><Icon id='sign-out' fixedWidth /></a>
        </nav>
      );
    }

    return (
      <div className='drawer' role='region' aria-label={intl.formatMessage(messages.compose)}>
        {header}

        {(multiColumn || isSearchPage) && <SearchContainer /> }

        <div className='drawer__pager'>
          {!isSearchPage && <div className='drawer__inner' onFocus={this.onFocus}>
            <NavigationContainer onClose={this.onBlur} />

            <ComposeFormContainer autoFocus={!isMobile(window.innerWidth)} />

            <div className='drawer__inner__mastodon'>
              {instanceMascot}
            </div>
          </div>}

          <Motion defaultStyle={{ x: isSearchPage ? 0 : -100 }} style={{ x: spring(showSearch || isSearchPage ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
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

}
