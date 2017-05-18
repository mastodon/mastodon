import React from 'react';
import PropTypes from 'prop-types';

class TextIconButton extends React.PureComponent {

  static propTypes = {
    label: PropTypes.string.isRequired,
    title: PropTypes.string,
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    ariaControls: PropTypes.string
  };

  handleClick = (e) => {
    e.preventDefault();
    this.props.onClick();
  }

  render () {
    const { label, title, active, ariaControls } = this.props;

    return (
      <button title={title} aria-label={title} className={`text-icon-button ${active ? 'active' : ''}`} aria-expanded={active} onClick={this.handleClick} aria-controls={ariaControls}>
        {label}
      </button>
    );
  }

}

export default TextIconButton;
