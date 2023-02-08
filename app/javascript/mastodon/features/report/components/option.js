import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import Check from 'mastodon/components/check';

export default class Option extends React.PureComponent {

  static propTypes = {
    name: PropTypes.string.isRequired,
    value: PropTypes.string.isRequired,
    checked: PropTypes.bool,
    label: PropTypes.node,
    description: PropTypes.node,
    onToggle: PropTypes.func,
    multiple: PropTypes.bool,
    labelComponent: PropTypes.node,
  };

  handleKeyPress = e => {
    const { value, checked, onToggle } = this.props;

    if (e.key === 'Enter' || e.key === ' ') {
      e.stopPropagation();
      e.preventDefault();
      onToggle(value, !checked);
    }
  };

  handleChange = e => {
    const { value, onToggle } = this.props;
    onToggle(value, e.target.checked);
  };

  render () {
    const { name, value, checked, label, labelComponent, description, multiple } = this.props;

    return (
      <label className='dialog-option poll__option selectable'>
        <input type={multiple ? 'checkbox' : 'radio'} name={name} value={value} checked={checked} onChange={this.handleChange} />

        <span
          className={classNames('poll__input', { active: checked, checkbox: multiple })}
          tabIndex='0'
          role='radio'
          onKeyPress={this.handleKeyPress}
          aria-checked={checked}
          aria-label={label}
        >{checked && <Check />}</span>

        {labelComponent ? labelComponent : (
          <span className='poll__option__text'>
            <strong>{label}</strong>
            {description}
          </span>
        )}
      </label>
    );
  }

}
