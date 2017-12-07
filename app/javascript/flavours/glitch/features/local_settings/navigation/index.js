//  Package imports
import React from 'react';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';

//  Our imports
import LocalSettingsNavigationItem from './item';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

const messages = defineMessages({
  general: {  id: 'settings.general', defaultMessage: 'General' },
  collapsed: { id: 'settings.collapsed_statuses', defaultMessage: 'Collapsed toots' },
  media: { id: 'settings.media', defaultMessage: 'Media' },
  preferences: { id: 'settings.preferences', defaultMessage: 'Preferences' },
  close: { id: 'settings.close', defaultMessage: 'Close' },
});

@injectIntl
export default class LocalSettingsNavigation extends React.PureComponent {

  static propTypes = {
    index      : PropTypes.number,
    intl       : PropTypes.object.isRequired,
    onClose    : PropTypes.func.isRequired,
    onNavigate : PropTypes.func.isRequired,
  };

  render () {

    const { index, intl, onClose, onNavigate } = this.props;

    return (
      <nav className='glitch local-settings__navigation'>
        <LocalSettingsNavigationItem
          active={index === 0}
          index={0}
          onNavigate={onNavigate}
          title={intl.formatMessage(messages.general)}
        />
        <LocalSettingsNavigationItem
          active={index === 1}
          index={1}
          onNavigate={onNavigate}
          title={intl.formatMessage(messages.collapsed)}
        />
        <LocalSettingsNavigationItem
          active={index === 2}
          index={2}
          onNavigate={onNavigate}
          title={intl.formatMessage(messages.media)}
        />
        <LocalSettingsNavigationItem
          active={index === 3}
          href='/settings/preferences'
          index={3}
          icon='cog'
          title={intl.formatMessage(messages.preferences)}
        />
        <LocalSettingsNavigationItem
          active={index === 4}
          className='close'
          index={4}
          onNavigate={onClose}
          title={intl.formatMessage(messages.close)}
        />
      </nav>
    );
  }

}
