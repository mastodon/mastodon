import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

export default class RadioButton extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    checked: PropTypes.bool,
    name: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    label: PropTypes.node.isRequired,
  };

  render () {
    const { name, value, checked, onChange, label } = this.props;

    return (
      <label className='radio-button'>
        <input
          name={name}
          type='radio'
          value={value}
          checked={checked}
          onChange={onChange}
        />

        <span className={classNames('radio-button__input', { checked })} />

        <span>{label}</span>
      </label>
    );
  }

}
