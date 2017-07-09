import React from 'react';
import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';
import PropTypes from 'prop-types';

export default class DropdownMenu extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    icon: PropTypes.string.isRequired,
    items: PropTypes.array.isRequired,
    size: PropTypes.number.isRequired,
    direction: PropTypes.string,
    ariaLabel: PropTypes.string,
  };

  static defaultProps = {
    ariaLabel: 'Menu',
  };

  state = {
    direction: 'left',
    expanded: false,
  };

  setRef = (c) => {
    this.dropdown = c;
  }

  handleClick = (e) => {
    const i = Number(e.currentTarget.getAttribute('data-index'));
    const { action, to } = this.props.items[i];

    // Don't call e.preventDefault() when the item uses 'href' property.
    // ex. "Edit profile" on the account action bar

    if (typeof action === 'function') {
      e.preventDefault();
      action();
    } else if (to) {
      e.preventDefault();
      this.context.router.history.push(to);
    }

    this.dropdown.hide();
  }

  handleShow = () => this.setState({ expanded: true })

  handleHide = () => this.setState({ expanded: false })

  renderItem = (item, i) => {
    if (item === null) {
      return <li key={`sep-${i}`} className='dropdown__sep' />;
    }

    const { text, href = '#' } = item;

    return (
      <li className='dropdown__content-list-item' key={`${text}-${i}`}>
        <a href={href} target='_blank' rel='noopener' onClick={this.handleClick} data-index={i} className='dropdown__content-list-link'>
          {text}
        </a>
      </li>
    );
  }

  render () {
    const { icon, items, size, direction, ariaLabel } = this.props;
    const { expanded } = this.state;
    const directionClass = (direction === 'left') ? 'dropdown__left' : 'dropdown__right';

    const dropdownItems = expanded && (
      <ul className='dropdown__content-list'>
        {items.map(this.renderItem)}
      </ul>
    );

    return (
      <Dropdown ref={this.setRef} onShow={this.handleShow} onHide={this.handleHide}>
        <DropdownTrigger className='icon-button' style={{ fontSize: `${size}px`, width: `${size}px`, lineHeight: `${size}px` }} aria-label={ariaLabel}>
          <i className={`fa fa-fw fa-${icon} dropdown__icon`}  aria-hidden />
        </DropdownTrigger>

        <DropdownContent className={directionClass}>
          {dropdownItems}
        </DropdownContent>
      </Dropdown>
    );
  }

}
