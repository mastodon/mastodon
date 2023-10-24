//  Package imports
import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import classNames from 'classnames';

import { Icon } from 'flavours/glitch/components/icon';

export default class LocalSettingsPage extends PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    className: PropTypes.string,
    href: PropTypes.string,
    icon: PropTypes.string,
    textIcon: PropTypes.string,
    iconComponent: PropTypes.func,
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
  };

  render () {
    const { handleClick } = this;
    const {
      active,
      className,
      href,
      icon,
      iconComponent,
      textIcon,
      onNavigate,
      title,
    } = this.props;

    const finalClassName = classNames('glitch', 'local-settings__navigation__item', {
      active,
    }, className);

    const iconElem = icon ? <Icon id={icon} icon={iconComponent} /> : (textIcon ? <span className='text-icon-button'>{textIcon}</span> : null);

    if (href) return (
      <a
        href={href}
        className={finalClassName}
        title={title}
        aria-label={title}
      >
        {iconElem} <span>{title}</span>
      </a>
    );
    else if (onNavigate) return (
      <button
        onClick={handleClick}
        className={finalClassName}
        title={title}
        aria-label={title}
      >
        {iconElem} <span>{title}</span>
      </button>
    );
    else return null;
  }

}
