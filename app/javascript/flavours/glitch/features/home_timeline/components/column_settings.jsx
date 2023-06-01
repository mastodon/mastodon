import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';

import SettingText from 'flavours/glitch/components/setting_text';
import SettingToggle from 'flavours/glitch/features/notifications/components/setting_toggle';

const messages = defineMessages({
  filter_regex: { id: 'home.column_settings.filter_regex', defaultMessage: 'Filter out by regular expressions' },
  settings: { id: 'home.settings', defaultMessage: 'Column settings' },
});

class ColumnSettings extends PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { settings, onChange, intl } = this.props;

    return (
      <div>
        <span className='column-settings__section'><FormattedMessage id='home.column_settings.basic' defaultMessage='Basic' /></span>

        <div className='column-settings__row'>
          <SettingToggle prefix='home_timeline' settings={settings} settingPath={['shows', 'reblog']} onChange={onChange} label={<FormattedMessage id='home.column_settings.show_reblogs' defaultMessage='Show boosts' />} />
        </div>

        <div className='column-settings__row'>
          <SettingToggle prefix='home_timeline' settings={settings} settingPath={['shows', 'reply']} onChange={onChange} label={<FormattedMessage id='home.column_settings.show_replies' defaultMessage='Show replies' />} />
        </div>

        <div className='column-settings__row'>
          <SettingToggle prefix='home_timeline' settings={settings} settingPath={['shows', 'direct']} onChange={onChange} label={<FormattedMessage id='home.column_settings.show_direct' defaultMessage='Show DMs' />} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='home.column_settings.advanced' defaultMessage='Advanced' /></span>

        <div className='column-settings__row'>
          <SettingText prefix='home_timeline' settings={settings} settingPath={['regex', 'body']} onChange={onChange} label={intl.formatMessage(messages.filter_regex)} />
        </div>
      </div>
    );
  }

}

export default injectIntl(ColumnSettings);
