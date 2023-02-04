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

  handleClick = (e) => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      if (this.props.onInterceptClick && this.props.onInterceptClick()) {
        e.preventDefault();
        return;
      }

      if (this.context.router) {
        e.preventDefault();
        let state = { ...this.context.router.history.location.state };
        state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
        this.context.router.history.push(this.props.to, state);
      }
    }
  };

  render () {
    const {
      children,
      className,
      href,
      to,
      onInterceptClick,
      ...other
    } = this.props;

    return (
      <a target='_blank' href={href} onClick={this.handleClick} {...other} className={`permalink${className ? ' ' + className : ''}`}>
        {children}
      </a>
    );
  }

}
