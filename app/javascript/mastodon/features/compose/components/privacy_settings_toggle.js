import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import SettingToggle from '../../notifications/components/setting_toggle';

export default class PrivacySettingsToggle extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
  };

  render () {
    const { settings, onChange } = this.props;

    const federateStr = <FormattedMessage id='privacy.federate' defaultMessage='Deliver to other instances' />;

    return (
      <div className='privacy-dropdown__federate'>
        <SettingToggle settings={settings} settingKey={['federate']} onChange={onChange} label={federateStr} />
      </div>
    );
  }

}
