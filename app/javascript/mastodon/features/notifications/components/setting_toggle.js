import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';

class SettingToggle extends React.PureComponent {
  onChange = (e) => {
    this.props.onChange(this.props.settingKey, e.target.checked);
  }

  render () {
    const { settings, settingKey, label, onChange, htmlFor = '' } = this.props;

    return (
    <label htmlFor={htmlFor} className='setting-toggle__label'>
        <Toggle checked={settings.getIn(settingKey)} onChange={this.onChange} />
        <span className='setting-toggle'>{label}</span>
      </label>
    )
  }
}

SettingToggle.propTypes = {
  settings: ImmutablePropTypes.map.isRequired,
  settingKey: PropTypes.array.isRequired,
  label: PropTypes.node.isRequired,
  onChange: PropTypes.func.isRequired,
  htmlFor: PropTypes.string
};

export default SettingToggle;
