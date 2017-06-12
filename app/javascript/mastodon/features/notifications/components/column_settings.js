import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { clearNotifications } from '../../../actions/notifications';
import { openModal } from '../../../actions/modal';
import ColumnCollapsable from '../../../components/column_collapsable';
import ClearColumnButton from './clear_column_button';
import SettingToggle from './setting_toggle';

const messages = defineMessages({
  settings: { id: 'notifications.settings', defaultMessage: 'Column settings' },
  clearMessage: { id: 'notifications.clear_confirmation', defaultMessage: 'Are you sure you want to permanently clear all your notifications?' },
  clearConfirm: { id: 'notifications.clear', defaultMessage: 'Clear notifications' },
});

class ColumnSettings extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    dispatch: PropTypes.func.isRequired,
    onChange: PropTypes.func.isRequired,
    onSave: PropTypes.func.isRequired,
    intl: PropTypes.shape({
      formatMessage: PropTypes.func.isRequired,
    }).isRequired,
  };

  handleClear = () => {
    const { dispatch, intl } = this.props;

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.clearMessage),
      confirm: intl.formatMessage(messages.clearConfirm),
      onConfirm: () => dispatch(clearNotifications()),
    }));
  }

  render () {
    const { settings, intl, onChange, onSave } = this.props;

    const alertStr = <FormattedMessage id='notifications.column_settings.alert' defaultMessage='Desktop notifications' />;
    const showStr  = <FormattedMessage id='notifications.column_settings.show' defaultMessage='Show in column' />;
    const soundStr = <FormattedMessage id='notifications.column_settings.sound' defaultMessage='Play sound' />;

    return (
      <div>
        <div className='column-settings__row'>
          <ClearColumnButton onClick={this.handleClear} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.follow' defaultMessage='New followers:' /></span>

        <div className='column-settings__row'>
          <SettingToggle settings={settings} settingKey={['alerts', 'follow']} onChange={onChange} label={alertStr} />
          <SettingToggle settings={settings} settingKey={['shows', 'follow']} onChange={onChange} label={showStr} />
          <SettingToggle settings={settings} settingKey={['sounds', 'follow']} onChange={onChange} label={soundStr} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.favourite' defaultMessage='Favourites:' /></span>

        <div className='column-settings__row'>
          <SettingToggle settings={settings} settingKey={['alerts', 'favourite']} onChange={onChange} label={alertStr} />
          <SettingToggle settings={settings} settingKey={['shows', 'favourite']} onChange={onChange} label={showStr} />
          <SettingToggle settings={settings} settingKey={['sounds', 'favourite']} onChange={onChange} label={soundStr} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.mention' defaultMessage='Mentions:' /></span>

        <div className='column-settings__row'>
          <SettingToggle settings={settings} settingKey={['alerts', 'mention']} onChange={onChange} label={alertStr} />
          <SettingToggle settings={settings} settingKey={['shows', 'mention']} onChange={onChange} label={showStr} />
          <SettingToggle settings={settings} settingKey={['sounds', 'mention']} onChange={onChange} label={soundStr} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='notifications.column_settings.reblog' defaultMessage='Boosts:' /></span>

        <div className='column-settings__row'>
          <SettingToggle settings={settings} settingKey={['alerts', 'reblog']} onChange={onChange} label={alertStr} />
          <SettingToggle settings={settings} settingKey={['shows', 'reblog']} onChange={onChange} label={showStr} />
          <SettingToggle settings={settings} settingKey={['sounds', 'reblog']} onChange={onChange} label={soundStr} />
        </div>
      </div>
    );
  }

}

export default connect()(injectIntl(ColumnSettings));
