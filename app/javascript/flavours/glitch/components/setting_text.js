import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

export default class SettingText extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    settingPath: PropTypes.array.isRequired,
    label: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
  };

  handleChange = (e) => {
    this.props.onChange(this.props.settingPath, e.target.value);
  }

  render () {
    const { settings, settingPath, label } = this.props;

    return (
      <label>
        <span style={{ display: 'none' }}>{label}</span>
        <input
          className='setting-text'
          value={settings.getIn(settingPath)}
          onChange={this.handleChange}
          placeholder={label}
        />
      </label>
    );
  }

}
