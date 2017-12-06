//  Package imports
import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

//  Stylesheet imports
import './style.scss';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

export default class LocalSettingsPage extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    className: PropTypes.string,
    href: PropTypes.string,
    icon: PropTypes.string,
    index: PropTypes.number.isRequired,
    onNavigate: PropTypes.func,
    title: PropTypes.string,
  };

  handleClick = (e) => {
    const { index, onNavigate } = this.props;
    if (onNavigate) {
      onNavigate(index);
      e.preventDefault();
    }
  }

  render () {
    const { handleClick } = this;
    const {
      active,
      className,
      href,
      icon,
      onNavigate,
      title,
    } = this.props;

    const finalClassName = classNames('glitch', 'local-settings__navigation__item', {
      active,
    }, className);

    const iconElem = icon ? <i className={`fa fa-fw fa-${icon}`} /> : null;

    if (href) return (
      <a
        href={href}
        className={finalClassName}
      >
        {iconElem} {title}
      </a>
    );
    else if (onNavigate) return (
      <a
        onClick={handleClick}
        role='button'
        tabIndex='0'
        className={finalClassName}
      >
        {iconElem} {title}
      </a>
    );
    else return null;
  }

}
