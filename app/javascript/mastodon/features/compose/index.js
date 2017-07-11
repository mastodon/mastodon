import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose } from '../../actions/compose';
import Link from 'react-router-dom/Link';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';
import SearchContainer from './containers/search_container';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';
import SearchResultsContainer from './containers/search_results_container';

const messages = defineMessages({
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  settings_subheading: { id: 'column_subheading.settings', defaultMessage: 'Settings' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
});

const mapStateToProps = state => ({
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
});

@connect(mapStateToProps)
@injectIntl
export default class Compose extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
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

  render () {
    const { multiColumn, showSearch, intl } = this.props;

    return (
      <div className='drawer'>

        <SearchContainer />

        <div className='drawer__pager'>
          <div className='drawer__inner'>
            <NavigationContainer />
            <ComposeFormContainer />
            <ColumnSubheading text={intl.formatMessage(messages.settings_subheading)} />
            <ColumnLink icon='book' text={intl.formatMessage(messages.info)} href='/about/more' />
            <ColumnLink icon='cog' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />
            <ColumnLink icon='sign-out' text={intl.formatMessage(messages.logout)} href='/auth/sign_out' method='delete' />

            <div className='getting-started__footer scrollable optionally-scrollable'>
              <div className='static-content getting-started'>
                <p>
                  <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.faq' defaultMessage='FAQ' /></a> • <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/User-guide.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.userguide' defaultMessage='User Guide' /></a> • <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.appsshort' defaultMessage='Apps' /></a>
                </p>
                <p>
                  <FormattedMessage
                    id='getting_started.open_source_notice'
                    defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.'
                    values={{ github: <a href='https://github.com/tootsuite/mastodon' rel='noopener' target='_blank'>tootsuite/mastodon</a> }}
                  />
                </p>
              </div>
            </div>
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
