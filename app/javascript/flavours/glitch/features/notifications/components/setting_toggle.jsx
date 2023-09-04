import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';

import Toggle from 'react-toggle';

export default class SettingToggle extends PureComponent {

  static propTypes = {
    prefix: PropTypes.string,
    settings: ImmutablePropTypes.map.isRequired,
    settingPath: PropTypes.array.isRequired,
    label: PropTypes.node.isRequired,
    meta: PropTypes.node,
    onChange: PropTypes.func.isRequired,
    defaultValue: PropTypes.bool,
    disabled: PropTypes.bool,
  };

  onChange = ({ target }) => {
    this.props.onChange(this.props.settingPath, target.checked);
  };

  render () {
    const { prefix, settings, settingPath, label, meta, defaultValue, disabled } = this.props;
    const id = ['setting-toggle', prefix, ...settingPath].filter(Boolean).join('-');

    return (
      <div className='setting-toggle'>
        <Toggle disabled={disabled} id={id} checked={settings.getIn(settingPath, defaultValue)} onChange={this.onChange} onKeyDown={this.onKeyDown} />
        <label htmlFor={id} className='setting-toggle__label'>{label}</label>
        {meta && <span className='setting-meta__label'>{meta}</span>}
      </div>
    );
  }

}
