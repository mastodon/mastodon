import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';

class SettingToggle extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    settingKey: PropTypes.array.isRequired,
    label: PropTypes.node.isRequired,
    onChange: PropTypes.func.isRequired,
  }

  onChange = (e) => {
    this.props.onChange(this.props.settingKey, e.target.checked);
  }

  render () {
    const { settings, settingKey, label, onChange } = this.props;
    const id = `setting-toggle-${settingKey.join('-')}`;

    return (
      <div className='setting-toggle'>
        <Toggle id={id} checked={settings.getIn(settingKey)} onChange={this.onChange} />
        <label htmlFor={id} className='setting-toggle__label'>{label}</label>
      </div>
    );
  }

}

export default SettingToggle;
