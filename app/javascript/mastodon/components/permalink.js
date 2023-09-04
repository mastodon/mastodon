import React from 'react';
import PropTypes from 'prop-types';

export default class Permalink extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    className: PropTypes.string,
    href: PropTypes.string.isRequired,
    to: PropTypes.string.isRequired,
    children: PropTypes.node,
    onInterceptClick: PropTypes.func,
  };

  handleClick = e => {
    if (this.props.onInterceptClick && this.props.onInterceptClick()) {
      e.preventDefault();
      return;
    }

    if (this.context.router && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(this.props.to);
    }
  }

  render () {
    const { href, children, className, onInterceptClick, ...other } = this.props;

    return (
      <a target='_blank' href={href} onClick={this.handleClick} {...other} className={`permalink${className ? ' ' + className : ''}`}>
        {children}
      </a>
    );
  }

}
