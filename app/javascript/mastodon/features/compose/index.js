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
  instanceMascot = <svg xmlns='http://www.w3.org/2000/svg' x='0px' y='0px' id='hometownlogo' preserveAspectRatio='xMidYMid meet' width='100%' height='100%' viewBox='25 40 50 20'><g><path d='M55.9,53.9H35.3c-0.7,0-1.3,0.6-1.3,1.3s0.6,1.3,1.3,1.3h20.6c0.7,0,1.3-0.6,1.3-1.3S56.6,53.9,55.9,53.9z'/><path d='M55.9,58.2H35.3c-0.7,0-1.3,0.6-1.3,1.3s0.6,1.3,1.3,1.3h20.6c0.7,0,1.3-0.6,1.3-1.3S56.6,58.2,55.9,58.2z'/><path d='M55.9,62.6H35.3c-0.7,0-1.3,0.6-1.3,1.3s0.6,1.3,1.3,1.3h20.6c0.7,0,1.3-0.6,1.3-1.3S56.6,62.6,55.9,62.6z'/><path d='M64.8,53.9c-0.7,0-1.3,0.6-1.3,1.3v8.8c0,0.7,0.6,1.3,1.3,1.3s1.3-0.6,1.3-1.3v-8.8C66,54.4,65.4,53.9,64.8,53.9z'/><path d='M60.4,53.9c-0.7,0-1.3,0.6-1.3,1.3v8.8c0,0.7,0.6,1.3,1.3,1.3s1.3-0.6,1.3-1.3v-8.8C61.6,54.4,61.1,53.9,60.4,53.9z'/><path d='M63.7,48.3c1.3-0.7,2-2.5,2-5.6c0-3.6-0.9-7.8-3.3-7.8s-3.3,4.2-3.3,7.8c0,3.1,0.7,4.9,2,5.6v2.4c0,0.7,0.6,1.3,1.3,1.3   s1.3-0.6,1.3-1.3V48.3z M62.4,37.8c0.4,0.8,0.8,2.5,0.8,4.9c0,2.5-0.5,3.4-0.8,3.4s-0.8-0.9-0.8-3.4C61.7,40.3,62.1,38.6,62.4,37.8   z'/><path d='M57,42.7c0-0.1-0.1-0.1-0.1-0.2l-3.2-4.1c-0.2-0.3-0.6-0.5-1-0.5h-1.6v-1.9c0-0.7-0.6-1.3-1.3-1.3s-1.3,0.6-1.3,1.3V38   h-3.9h-1.1h-5.2c-0.4,0-0.7,0.2-1,0.5l-3.2,4.1c0,0.1-0.1,0.1-0.1,0.2c0,0-0.1,0.1-0.1,0.1C34,43,34,43.2,34,43.3v7.4   c0,0.7,0.6,1.3,1.3,1.3h5.2h7.4h8c0.7,0,1.3-0.6,1.3-1.3v-7.4c0-0.2,0-0.3-0.1-0.4C57,42.8,57,42.8,57,42.7z M41.7,49.5h-5.2v-4.9   h10.2v4.9H41.7z M48.5,42.1l-1.2-1.6h4.8l1.2,1.6H48.5z M44.1,40.5l1.2,1.6h-7.5l1.2-1.6H44.1z M49.2,44.6h5.5v4.9h-5.5V44.6z'/></g></svg>;
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

            <ComposeFormContainer />

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
