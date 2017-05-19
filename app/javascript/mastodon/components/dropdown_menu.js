import React from 'react';
import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';
import PropTypes from 'prop-types';

class DropdownMenu extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object
  };

  static propTypes = {
    icon: PropTypes.string.isRequired,
    items: PropTypes.array.isRequired,
    size: PropTypes.number.isRequired,
    direction: PropTypes.string,
    ariaLabel: PropTypes.string,
  };

  static defaultProps = {
    ariaLabel: "Menu",
  };

  state = {
    direction: 'left',
  };

  setRef = (c) => {
    this.dropdown = c;
  }

  handleClick = (e) => {
    const i = Number(e.currentTarget.getAttribute('data-index'));
    const { action, to } = this.props.items[i];

    e.preventDefault();

    if (typeof action === 'function') {
      action();
    } else if (to) {
      this.context.router.push(to);
    }

    this.dropdown.hide();
  }

  renderItem = (item, i) => {
    if (item === null) {
      return <li key={ 'sep' + i } className='dropdown__sep' />;
    }

    const { text, action, href = '#' } = item;

    return (
      <li className='dropdown__content-list-item' key={ text + i }>
        <a href={href} target='_blank' rel='noopener' onClick={this.handleClick} data-index={i} className='dropdown__content-list-link'>
          {text}
        </a>
      </li>
    );
  }

  render () {
    const { icon, items, size, direction, ariaLabel } = this.props;
    const directionClass = (direction === "left") ? "dropdown__left" : "dropdown__right";

    return (
      <Dropdown ref={this.setRef}>
        <DropdownTrigger className='icon-button' style={{ fontSize: `${size}px`, width: `${size}px`, lineHeight: `${size}px` }} aria-label={ariaLabel}>
          <i className={ `fa fa-fw fa-${icon} dropdown__icon` }  aria-hidden={true} />
        </DropdownTrigger>

        <DropdownContent className={directionClass}>
          <ul className='dropdown__content-list'>
            {items.map(this.renderItem)}
          </ul>
        </DropdownContent>
      </Dropdown>
    );
  }

}

export default DropdownMenu;
