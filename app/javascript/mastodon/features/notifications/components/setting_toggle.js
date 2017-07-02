import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';

export default class SettingToggle extends React.PureComponent {

  static propTypes = {
    prefix: PropTypes.string,
    settings: ImmutablePropTypes.map.isRequired,
    settingKey: PropTypes.array.isRequired,
    label: PropTypes.node.isRequired,
    onChange: PropTypes.func.isRequired,
  }

  onChange = ({ target }) => {
    this.props.onChange(this.props.settingKey, target.checked);
  }

  render () {
    const { prefix, settings, settingKey, label } = this.props;
    const id = ['setting-toggle', prefix, ...settingKey].filter(Boolean).join('-');

    return (
      <div className='setting-toggle'>
        <Toggle id={id} checked={settings.getIn(settingKey)} onChange={this.onChange} />
        <label htmlFor={id} className='setting-toggle__label'>{label}</label>
      </div>
    );
  }

}
