import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import SettingToggle from '../components/setting_toggle';
import { Map as ImmutableMap } from 'immutable';

const messages = defineMessages({
  show_local_only: { id: 'tag.column_settings.show_local_only', defaultMessage: 'Show local only' },
});

@injectIntl
export default class ShowLocalSettings extends React.PureComponent {

  static propTypes = {
    tag: PropTypes.string.isRequired,
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { tag, settings, onChange, intl } = this.props;
    const initialSettings = ImmutableMap({
      shows: ImmutableMap({
        local: false,
      }),
    });

    return (
      <div>
        <div className='column-settings__row'>
          <SettingToggle tag={tag} prefix='hashtag_timeline' settings={settings.get(`${tag}`, initialSettings)} settingKey={['shows', 'local']} onChange={onChange} label={intl.formatMessage(messages.show_local_only)} />
        </div>
      </div>
    );
  }

}
