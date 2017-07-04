import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import ClearColumnButton from './clear_column_button';
import SettingToggle from './setting_toggle';

export default class ColumnSettings extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    onSave: PropTypes.func.isRequired,
    onClear: PropTypes.func.isRequired,
  };

  render () {
    const { settings, onChange, onClear } = this.props;

    const alertStr = <FormattedMessage id='notifications.column_settings.alert' defaultMessage='Desktop notifications' />;
    const showStr  = <FormattedMessage id='notifications.column_settings.show' defaultMessage='Show in column' />;
    const soundStr = <FormattedMessage id='notifications.column_settings.sound' defaultMessage='Play sound' />;

    return (
      <div>
        <div className='column-settings__row'>
          <ClearColumnButton onClick={onClear} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.follow' defaultMessage='New followers:' /></span>

        <div className='column-settings__row'>
          <SettingToggle prefix='notifications' settings={settings} settingKey={['alerts', 'follow']} onChange={onChange} label={alertStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['shows', 'follow']} onChange={onChange} label={showStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['sounds', 'follow']} onChange={onChange} label={soundStr} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.favourite' defaultMessage='Favourites:' /></span>

        <div className='column-settings__row'>
          <SettingToggle prefix='notifications' settings={settings} settingKey={['alerts', 'favourite']} onChange={onChange} label={alertStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['shows', 'favourite']} onChange={onChange} label={showStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['sounds', 'favourite']} onChange={onChange} label={soundStr} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.mention' defaultMessage='Mentions:' /></span>

        <div className='column-settings__row'>
          <SettingToggle prefix='notifications' settings={settings} settingKey={['alerts', 'mention']} onChange={onChange} label={alertStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['shows', 'mention']} onChange={onChange} label={showStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['sounds', 'mention']} onChange={onChange} label={soundStr} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.reblog' defaultMessage='Boosts:' /></span>

        <div className='column-settings__row'>
          <SettingToggle prefix='notifications' settings={settings} settingKey={['alerts', 'reblog']} onChange={onChange} label={alertStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['shows', 'reblog']} onChange={onChange} label={showStr} />
          <SettingToggle prefix='notifications' settings={settings} settingKey={['sounds', 'reblog']} onChange={onChange} label={soundStr} />
        </div>
      </div>
    );
  }

}
