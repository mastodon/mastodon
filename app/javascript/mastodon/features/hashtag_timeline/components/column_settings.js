import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';
import AsyncSelect from 'react-select/lib/Async';

export default @injectIntl
class ColumnSettings extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    onLoad: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    open: this.hasTags(),
  };

  hasTags () {
    return ['all', 'any', 'none'].map(mode => this.tags(mode).length > 0).includes(true);
  }

  tags (mode) {
    let tags = this.props.settings.getIn(['tags', mode]) || [];
    if (tags.toJSON) {
      return tags.toJSON();
    } else {
      return tags;
    }
  };

  onSelect = (mode) => {
    return (value) => {
      this.props.onChange(['tags', mode], value);
    };
  };

  onToggle = () => {
    if (this.state.open && this.hasTags()) {
      this.props.onChange('tags', {});
    }
    this.setState({ open: !this.state.open });
  };

  modeSelect (mode) {
    return (
      <div className='column-settings__section'>
        {this.modeLabel(mode)}
        <AsyncSelect
          isMulti
          autoFocus
          value={this.tags(mode)}
          settings={this.props.settings}
          settingPath={['tags', mode]}
          onChange={this.onSelect(mode)}
          loadOptions={this.props.onLoad}
          classNamePrefix='column-settings__hashtag-select'
          name='tags'
        />
      </div>
    );
  }

  modeLabel (mode) {
    switch(mode) {
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
            {this.modeSelect('any')}
            {this.modeSelect('all')}
            {this.modeSelect('none')}
          </div>
        }
      </div>
    );
  }

}
