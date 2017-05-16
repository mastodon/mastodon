import React from 'react';
import PropTypes from 'prop-types';

class Permalink extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object
  };

  static propTypes = {
    className: PropTypes.string,
    href: PropTypes.string.isRequired,
    to: PropTypes.string.isRequired,
    children: PropTypes.node
  };

  handleClick = (e) => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.push(this.props.to);
    }
  }

  render () {
    const { href, children, className, ...other } = this.props;

    return (
      <a href={href} onClick={this.handleClick} {...other} className={'permalink ' + className}>
        {children}
      </a>
    );
  }

}

export default Permalink;
