import classNames from 'classnames';
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';

export default class SettingToggle extends React.PureComponent {

  static propTypes = {
    prefix: PropTypes.string,
    disabled: PropTypes.bool,
    sub: PropTypes.bool,
    settings: ImmutablePropTypes.map.isRequired,
    settingKey: PropTypes.array.isRequired,
    label: PropTypes.node.isRequired,
    meta: PropTypes.node,
    onChange: PropTypes.func.isRequired,
  }

  onChange = ({ target }) => {
    this.props.onChange(this.props.settingKey, target.checked);
  }

  render () {
    const { prefix, disabled, sub, settings, settingKey, label, meta } = this.props;
    const id = ['setting-toggle', prefix, ...settingKey].filter(Boolean).join('-');

    return (
      <div className={classNames('setting-toggle', { 'setting-toggle_sub': sub })}>
        <Toggle id={id} checked={settings.getIn(settingKey)} disabled={disabled} onChange={this.onChange} onKeyDown={this.onKeyDown} />
        <label htmlFor={id} className='setting-toggle__label'>{label}</label>
        {meta && <span className='setting-meta__label'>{meta}</span>}
      </div>
    );
  }

}
