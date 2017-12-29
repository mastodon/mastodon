import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl } from 'react-intl';
import SettingsNavigation from '../settings_navigation';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import NavigationFooter from '../../components/navigation_footer';

const messages = defineMessages({
  heading: { id: 'settings.heading', defaultMessage: 'Settings' },
});

@injectIntl
export default class Settings extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl } = this.props;

    return (
      <Column icon='cog' heading={intl.formatMessage(messages.heading)} hideHeadingOnMobile>
        <ColumnBackButtonSlim />
        <SettingsNavigation />
        <NavigationFooter />
      </Column>
    );
  }

}
