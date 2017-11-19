//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import Toggle from 'react-toggle';

export default class ComposeAdvancedOptionsToggle extends React.PureComponent {

  static propTypes = {
    onChange: PropTypes.func.isRequired,
    active: PropTypes.bool.isRequired,
    name: PropTypes.string.isRequired,
    shortText: PropTypes.string.isRequired,
    longText: PropTypes.string.isRequired,
  }

  onToggle = () => {
    this.props.onChange(this.props.name);
  }

  render() {
    const { active, shortText, longText } = this.props;
    return (
      <div role='button' tabIndex='0' className='advanced-options-dropdown__option' onClick={this.onToggle}>
        <div className='advanced-options-dropdown__option__toggle'>
          <Toggle checked={active} onChange={this.onToggle} />
        </div>
        <div className='advanced-options-dropdown__option__content'>
          <strong>{shortText}</strong>
          {longText}
        </div>
      </div>
    );
  }

}
