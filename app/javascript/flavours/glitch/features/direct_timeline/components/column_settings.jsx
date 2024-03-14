import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';

import SettingToggle from 'flavours/glitch/features/notifications/components/setting_toggle';

import SettingText from '../../../components/setting_text';

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
      <div className='column-settings'>
        <section>
          <div className='column-settings__row'>
            <SettingToggle settings={settings} settingPath={['conversations']} onChange={onChange} label={<FormattedMessage id='direct.group_by_conversations' defaultMessage='Group by conversation' />} />
          </div>
        </section>

        <section>
          <h3><FormattedMessage id='home.column_settings.advanced' defaultMessage='Advanced' /></h3>

          <div className='column-settings__row'>
            <SettingText settings={settings} settingPath={['regex', 'body']} onChange={onChange} label={intl.formatMessage(messages.filter_regex)} />
          </div>
        </section>
      </div>
    );
  }

}

export default injectIntl(ColumnSettings);
