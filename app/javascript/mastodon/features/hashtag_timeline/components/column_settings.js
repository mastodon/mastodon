import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, FormattedMessage } from 'react-intl';
import SettingToggle from '../../notifications/components/setting_toggle';
import Toggle from 'react-toggle'
import AsyncSelect from 'react-select/lib/Async'

@injectIntl
export default class ColumnSettings extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    onLoad: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    open: this.tags().length > 0
  };

  tags() {
    return Array.from(this.props.settings.get('tags') || []).map((tag) => {
      return tag.toJSON ? tag.toJSON() : tag
    })
  };

  toggle(settings, onChange, value) {
    if (!value && this.tags().length > 0) { onChange('tags', []) }
    this.setState({ open: !this.state.open })
  };

  render () {
    const { settings, onChange, onLoad } = this.props;

    return (
      <div>
        <div className='column-settings__row'>
          <div className='setting-toggle'>
            <Toggle
              id='hashtag.column_settings.tag_toggle'
              onChange={() => { this.toggle(settings, onChange, !this.state.open) }}
              checked={this.state.open} />
            <span className='setting-toggle__label'>
              <FormattedMessage id='hashtag.column_settings.tag_toggle' defaultMessage='Include additional tags in this column' />
            </span>
          </div>
        </div>
        {this.state.open &&
          <div className="column-setting__hashtags">
            <div className="column-setting__row">
              <AsyncSelect
                isMulti
                autoFocus
                value={this.tags()}
                settings={settings}
                settingPath={['tags']}
                onChange={(value) => { onChange('tags', value) }}
                loadOptions={onLoad}
                className="column-settings__hashtag-select"
                name="tags" />
            </div>
            <div className='column-settings__row'>
              <SettingToggle prefix='additional_hashtags_or' settings={settings} settingPath={['orOperation']} onChange={onChange} label={
                <FormattedMessage id='hashtag.column_settings.include_tag_intersection' defaultMessage='Display toots with all of these hashtags' />
              } />
            </div>
          </div>
        }
      </div>
    );
  }

}
