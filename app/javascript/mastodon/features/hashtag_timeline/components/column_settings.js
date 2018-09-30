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
    open: this.tags().length > 0,
    mode: this.props.settings.get('tagMode') || 'all'
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

  isChecked(value) {
    return this.state.mode == value
  };

  check(value) {
    return () => {
      this.setState({ mode: value })
    }
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
          <div className='column-settings__hashtags'>
            <div className='column-settings__section'>
              <AsyncSelect
                isMulti
                autoFocus
                value={this.tags()}
                settings={settings}
                settingPath={['tags']}
                onChange={(value) => { onChange('tags', value) }}
                loadOptions={onLoad}
                className='column-settings__hashtag-select'
                name='tags' />
            </div>
            <div className='column-settings__section'>
              <ul>
                <li className='radio'>
                  <label>
                    <input className='radio_buttons' type='radio' value='all' name='tagMode' checked={this.isChecked('all')} onChange={this.check('all')} id='tag_mode_and' />
                    <FormattedMessage id='hashtag.column_settings.all_tags_mode' defaultMessage='All of these tags' />
                  </label>
                </li>
                <li className='radio'>
                  <label>
                    <input className='radio_buttons' type='radio' value='or' name='tagMode' checked={this.isChecked('or')} onChange={this.check('or')} id='tag_mode_or' />
                    <FormattedMessage id='hashtag.column_settings.any_tags_mode' defaultMessage='Any of these tags' />
                  </label>
                </li>
                <li className='radio'>
                  <label>
                    <input className='radio_buttons' type='radio' value='not' name='tagMode' checked={this.isChecked('not')} onChange={this.check('not')} id='tag_mode_not' />
                    <FormattedMessage id='hashtag.column_settings.none_tags_mode' defaultMessage='None of these tags' />
                  </label>
                </li>
              </ul>
            </div>
          </div>
        }
      </div>
    );
  }

}
