import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose } from 'themes/glitch/actions/compose';
import { openModal } from 'themes/glitch/actions/modal';
import { changeLocalSetting } from 'themes/glitch/actions/local_settings';
import { Link } from 'react-router-dom';
import { injectIntl, defineMessages } from 'react-intl';
import SearchContainer from './containers/search_container';
import Motion from 'themes/glitch/util/optional_motion';
import spring from 'react-motion/lib/spring';
import SearchResultsContainer from './containers/search_results_container';
import { changeComposing } from 'themes/glitch/actions/compose';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  settings: { id: 'navigation_bar.app_settings', defaultMessage: 'App settings' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
});

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
});

@connect(mapStateToProps)
@injectIntl
export default class Compose extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    this.props.dispatch(mountCompose());
  }

  componentWillUnmount () {
    this.props.dispatch(unmountCompose());
  }

  onLayoutClick = (e) => {
    const layout = e.currentTarget.getAttribute('data-mastodon-layout');
    this.props.dispatch(changeLocalSetting(['layout'], layout));
    e.preventDefault();
  }

  openSettings = () => {
    this.props.dispatch(openModal('SETTINGS', {}));
  }

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  }

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  }

  render () {
    const { multiColumn, showSearch, intl } = this.props;

    let header = '';

    if (multiColumn) {
      const { columns } = this.props;
      header = (
        <nav className='drawer__header'>
          <Link to='/getting-started' className='drawer__tab' title={intl.formatMessage(messages.start)} aria-label={intl.formatMessage(messages.start)}><i role='img' className='fa fa-fw fa-asterisk' /></Link>
          {!columns.some(column => column.get('id') === 'HOME') && (
            <Link to='/timelines/home' className='drawer__tab' title={intl.formatMessage(messages.home_timeline)} aria-label={intl.formatMessage(messages.home_timeline)}><i role='img' className='fa fa-fw fa-home' /></Link>
          )}
          {!columns.some(column => column.get('id') === 'NOTIFICATIONS') && (
            <Link to='/notifications' className='drawer__tab' title={intl.formatMessage(messages.notifications)} aria-label={intl.formatMessage(messages.notifications)}><i role='img' className='fa fa-fw fa-bell' /></Link>
          )}
          {!columns.some(column => column.get('id') === 'COMMUNITY') && (
            <Link to='/timelines/public/local' className='drawer__tab' title={intl.formatMessage(messages.community)} aria-label={intl.formatMessage(messages.community)}><i role='img' className='fa fa-fw fa-users' /></Link>
          )}
          {!columns.some(column => column.get('id') === 'PUBLIC') && (
            <Link to='/timelines/public' className='drawer__tab' title={intl.formatMessage(messages.public)} aria-label={intl.formatMessage(messages.public)}><i role='img' className='fa fa-fw fa-globe' /></Link>
          )}
          <a onClick={this.openSettings} role='button' tabIndex='0' className='drawer__tab' title={intl.formatMessage(messages.settings)} aria-label={intl.formatMessage(messages.settings)}><i role='img' className='fa fa-fw fa-cogs' /></a>
          <a href='/auth/sign_out' className='drawer__tab' data-method='delete' title={intl.formatMessage(messages.logout)} aria-label={intl.formatMessage(messages.logout)}><i role='img' className='fa fa-fw fa-sign-out' /></a>
        </nav>
      );
    }



    return (
      <div className='drawer'>
        {header}

        <SearchContainer />

        <div className='drawer__pager'>
          <div className='drawer__inner scrollable optionally-scrollable' onFocus={this.onFocus}>
            <NavigationContainer onClose={this.onBlur} />
            <ComposeFormContainer />
          </div>

          <Motion defaultStyle={{ x: -100 }} style={{ x: spring(showSearch ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
            {({ x }) =>
              <div className='drawer__inner darker' style={{ transform: `translateX(${x}%)`, visibility: x === -100 ? 'hidden' : 'visible' }}>
                <SearchResultsContainer />
              </div>
            }
          </Motion>
        </div>

      </div>
    );
  }

}
