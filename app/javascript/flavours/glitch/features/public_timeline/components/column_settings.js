import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, FormattedMessage } from 'react-intl';
import SettingToggle from '../../notifications/components/setting_toggle';

export default @injectIntl
class ColumnSettings extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
  };

  render () {
    const { settings, onChange } = this.props;

    return (
      <div>
        <div className='column-settings__row'>
          <SettingToggle settings={settings} settingPath={['other', 'onlyMedia']} onChange={onChange} label={<FormattedMessage id='community.column_settings.media_only' defaultMessage='Media only' />} />
          <SettingToggle settings={settings} settingPath={['other', 'onlyRemote']} onChange={onChange} label={<FormattedMessage id='community.column_settings.remote_only' defaultMessage='Remote only' />} />
          {!settings.getIn(['other', 'onlyRemote']) && <SettingToggle settings={settings} settingPath={['other', 'allowLocalOnly']} onChange={onChange} label={<FormattedMessage id='community.column_settings.allow_local_only' defaultMessage='Show local-only toots' />} />}
        </div>
      </div>
    );
  }

}
