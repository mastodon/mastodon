import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';
import AsyncSelect from 'react-select/lib/Async';

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
    mode: this.props.settings.get('tagMode') || 'any',
  };

  tags () {
    return Array.from(this.props.settings.get('tags') || []).map((tag) => {
      return tag.toJSON ? tag.toJSON() : tag;
    });
  };

  onSelect = (value) => {
    this.props.onChange('tags', value);
  };

  onToggle = () => {
    if (this.state.open && this.tags().length > 0) {
      this.props.onChange('tags', []);
    }
    this.setState({ open: !this.state.open });
  };

  setMode = (mode) => {
    return () => {
      this.props.onChange('tagMode', mode);
      this.setState({ mode });
    };
  };

  modeOption (value) {
    return (
      <li className='radio'>
        <label>
          <input
            id={`tag_mode_${value}`}
            className='radio_buttons'
            type='radio'
            value={value}
            name='tagMode'
            checked={this.state.mode === value}
            onChange={this.setMode(value)}
          />
          {this.modeLabel(value)}
        </label>
      </li>
    );
  };

  modeLabel (value) {
    switch(value) {
    case 'any':  return <FormattedMessage id='hashtag.column_settings.tag_mode.any' defaultMessage='Any of these' />;
    case 'all':  return <FormattedMessage id='hashtag.column_settings.tag_mode.all' defaultMessage='All of these' />;
    case 'none': return <FormattedMessage id='hashtag.column_settings.tag_mode.none' defaultMessage='None of these' />;
    }
    return '';
  };

  render () {
    return (
      <div>
        <div className='column-settings__row'>
          <div className='setting-toggle'>
            <Toggle
              id='hashtag.column_settings.tag_toggle'
              onChange={this.onToggle}
              checked={this.state.open}
            />
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
                settings={this.props.settings}
                settingPath={['tags']}
                onChange={this.onSelect}
                loadOptions={this.props.onLoad}
                className='column-settings__hashtag-select'
                name='tags'
              />
            </div>
            <div className='column-settings__section'>
              <ul>
                {this.modeOption('any')}
                {this.modeOption('all')}
                {this.modeOption('none')}
              </ul>
            </div>
          </div>
        }
      </div>
    );
  }

}
