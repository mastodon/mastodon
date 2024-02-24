//  Package imports
import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import ExpandLessIcon from '@/material-icons/400-24px/expand_less.svg?react';
import ImageIcon from '@/material-icons/400-24px/image.svg?react';
import ManufacturingIcon from '@/material-icons/400-24px/manufacturing.svg?react';
import SettingsIcon from '@/material-icons/400-24px/settings-fill.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';
import { preferencesLink } from 'flavours/glitch/utils/backend_links';

import LocalSettingsNavigationItem from './item';

const messages = defineMessages({
  general: {  id: 'settings.general', defaultMessage: 'General' },
  compose: {  id: 'settings.compose_box_opts', defaultMessage: 'Compose box' },
  content_warnings: { id: 'settings.content_warnings', defaultMessage: 'Content Warnings' },
  collapsed: { id: 'settings.collapsed_statuses', defaultMessage: 'Collapsed toots' },
  media: { id: 'settings.media', defaultMessage: 'Media' },
  preferences: { id: 'settings.preferences', defaultMessage: 'Preferences' },
  close: { id: 'settings.close', defaultMessage: 'Close' },
});

class LocalSettingsNavigation extends PureComponent {

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
          icon='cogs'
          iconComponent={ManufacturingIcon}
          title={intl.formatMessage(messages.general)}
        />
        <LocalSettingsNavigationItem
          active={index === 1}
          index={1}
          onNavigate={onNavigate}
          icon='pencil'
          iconComponent={EditIcon}
          title={intl.formatMessage(messages.compose)}
        />
        <LocalSettingsNavigationItem
          active={index === 2}
          index={2}
          onNavigate={onNavigate}
          icon='warning'
          iconComponent={WarningIcon}
          title={intl.formatMessage(messages.content_warnings)}
        />
        <LocalSettingsNavigationItem
          active={index === 3}
          index={3}
          onNavigate={onNavigate}
          icon='angle-double-up'
          iconComponent={ExpandLessIcon}
          title={intl.formatMessage(messages.collapsed)}
        />
        <LocalSettingsNavigationItem
          active={index === 4}
          index={4}
          onNavigate={onNavigate}
          icon='image'
          iconComponent={ImageIcon}
          title={intl.formatMessage(messages.media)}
        />
        <LocalSettingsNavigationItem
          active={index === 5}
          href={preferencesLink}
          index={5}
          icon='cog'
          iconComponent={SettingsIcon}
          title={intl.formatMessage(messages.preferences)}
        />
        <LocalSettingsNavigationItem
          active={index === 6}
          className='close'
          index={6}
          onNavigate={onClose}
          icon='times'
          iconComponent={CloseIcon}
          title={intl.formatMessage(messages.close)}
        />
      </nav>
    );
  }

}

export default injectIntl(LocalSettingsNavigation);
