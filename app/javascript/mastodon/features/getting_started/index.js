import React from 'react';
import Column from '../ui/components/column';
import ColumnLink from '../ui/components/column_link';
import MainNavigation from '../main_navigation';
import SettingsNavigation from '../settings_navigation';
import { defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import NavigationFooter from '../../components/navigation_footer';
import { me } from '../../initial_state';

const messages = defineMessages({
  heading: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  settings: { id: 'settings.heading', defaultMessage: 'Settings' },
});

const mapStateToProps = state => ({
  myAccount: state.getIn(['accounts', me]),
  columns: state.getIn(['settings', 'columns']),
});

@connect(mapStateToProps)
@injectIntl
export default class GettingStarted extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    myAccount: ImmutablePropTypes.map.isRequired,
    columns: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
  };

  state = {
    collapseSettings: true,
  };

  componentDidMount () {
    if (this.state.collapseSettings && this.navigation.clientHeight < this.navigation.scrollHeight) {
      this.setState({ collapseSettings: false });
    }
  }

  componentWillReceiveProps () {
    this.setState({ collapseSettings: true });
  }

  componentDidUpdate () {
    if (this.state.collapseSettings && this.navigation.clientHeight < this.navigation.scrollHeight) {
      this.setState({ collapseSettings: false });
    }
  }

  setRef = ref => {
    this.navigation = ref;
  };

  render () {
    const { intl, myAccount, columns, multiColumn } = this.props;

    return (
      <Column icon='asterisk' heading={intl.formatMessage(messages.heading)} hideHeadingOnMobile>
        <div className='navigation__wrapper' ref={this.setRef}>
          <MainNavigation followRequestsHidden={myAccount.get('locked')} hiddenColumns={columns} multiColumn={multiColumn} />
          {
            this.state.collapseSettings ?
              <SettingsNavigation /> :
              <ColumnLink key='12' icon='cog' text={intl.formatMessage(messages.settings)} to='/settings' />
          }
        </div>

        <NavigationFooter />
      </Column>
    );
  }

}
