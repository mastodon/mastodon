import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose } from '../../actions/compose';
import { openModal } from '../../actions/modal';
import { changeLocalSetting } from '../../actions/local_settings';
import Link from 'react-router-dom/Link';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';
import SearchContainer from './containers/search_container';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';
import SearchResultsContainer from './containers/search_results_container';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Federated timeline' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  settings: { id: 'navigation_bar.app_settings', defaultMessage: 'App settings' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
});

const mapStateToProps = state => ({
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
  layout: state.getIn(['local_settings', 'layout']),
});

@connect(mapStateToProps)
@injectIntl
export default class Compose extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    layout: PropTypes.string,
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

  render () {
    const { multiColumn, showSearch, intl, layout } = this.props;

    let header = '';

    if (multiColumn) {
      header = (
        <div className='drawer__header'>
          <Link to='/getting-started' className='drawer__tab' title={intl.formatMessage(messages.start)}><i role='img' aria-label={intl.formatMessage(messages.start)} className='fa fa-fw fa-asterisk' /></Link>
          <Link to='/timelines/public/local' className='drawer__tab' title={intl.formatMessage(messages.community)}><i role='img' aria-label={intl.formatMessage(messages.community)} className='fa fa-fw fa-users' /></Link>
          <Link to='/timelines/public' className='drawer__tab' title={intl.formatMessage(messages.public)}><i role='img' aria-label={intl.formatMessage(messages.public)} className='fa fa-fw fa-globe' /></Link>
          <a onClick={this.openSettings} role='button' tabIndex='0' className='drawer__tab' title={intl.formatMessage(messages.settings)}><i role='img' aria-label={intl.formatMessage(messages.settings)} className='fa fa-fw fa-cogs' /></a>
          <a href='/auth/sign_out' className='drawer__tab' data-method='delete' title={intl.formatMessage(messages.logout)}><i role='img' aria-label={intl.formatMessage(messages.logout)} className='fa fa-fw fa-sign-out' /></a>
        </div>
      );
    }

    let layoutContent = '';

    switch (layout) {
    case 'single':
      layoutContent = (
        <div className='layout__selector'>
          <p>
            <FormattedMessage id='layout.current_is' defaultMessage='Your current layout is:' /> <b><FormattedMessage id='layout.mobile' defaultMessage='Mobile' /></b>
          </p>
          <p>
            <a onClick={this.onLayoutClick} role='button' tabIndex='0' data-mastodon-layout='auto'><FormattedMessage id='layout.auto' defaultMessage='Auto' /></a> • <a onClick={this.onLayoutClick} role='button' tabIndex='0' data-mastodon-layout='multiple'><FormattedMessage id='layout.desktop' defaultMessage='Desktop' /></a>
          </p>
        </div>
      );
      break;
    case 'multiple':
      layoutContent = (
        <div className='layout__selector'>
          <p>
            <FormattedMessage id='layout.current_is' defaultMessage='Your current layout is:' /> <b><FormattedMessage id='layout.desktop' defaultMessage='Desktop' /></b>
          </p>
          <p>
            <a onClick={this.onLayoutClick} role='button' tabIndex='0' data-mastodon-layout='auto'><FormattedMessage id='layout.auto' defaultMessage='Auto' /></a> • <a onClick={this.onLayoutClick} role='button' tabIndex='0' data-mastodon-layout='single'><FormattedMessage id='layout.mobile' defaultMessage='Mobile' /></a>
          </p>
        </div>
      );
      break;
    default:
      layoutContent = (
        <div className='layout__selector'>
          <p>
            <FormattedMessage id='layout.current_is' defaultMessage='Your current layout is:' /> <b><FormattedMessage id='layout.auto' defaultMessage='Auto' /></b>
          </p>
          <p>
            <a onClick={this.onLayoutClick} role='button' tabIndex='0' data-mastodon-layout='multiple'><FormattedMessage id='layout.desktop' defaultMessage='Desktop' /></a> • <a onClick={this.onLayoutClick} role='button' tabIndex='0' data-mastodon-layout='single'><FormattedMessage id='layout.mobile' defaultMessage='Mobile' /></a>
          </p>
        </div>
      );
      break;
    }

    return (
      <div className='drawer'>
        {header}

        <SearchContainer />

        <div className='drawer__pager'>
          <div className='drawer__inner'>
            <NavigationContainer />
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

        {layoutContent}

      </div>
    );
  }

}
