import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';

const messages = defineMessages({
  settings_subheading: { id: 'settings.heading', defaultMessage: 'Settings' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  sign_out: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
});

@injectIntl
export default class Settings extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl } = this.props;

    return (
      <div>
        <ColumnSubheading text={intl.formatMessage(messages.settings_subheading)} />
        <ColumnLink icon='thumb-tack' text={intl.formatMessage(messages.pins)} to='/pinned' />
        <ColumnLink icon='volume-off' text={intl.formatMessage(messages.mutes)} to='/mutes' />
        <ColumnLink icon='ban' text={intl.formatMessage(messages.blocks)} to='/blocks' />
        <ColumnLink icon='sliders' text={intl.formatMessage(messages.preferences)} href='/settings/preferences' />
        <ColumnLink icon='sign-out' text={intl.formatMessage(messages.sign_out)} href='/auth/sign_out' method='delete' />
      </div>
    );
  }

}
