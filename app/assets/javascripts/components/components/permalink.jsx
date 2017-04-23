import PropTypes from 'prop-types';

class Permalink extends React.Component {

  constructor (props, context) {
    super(props, context);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick (e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(this.props.to);
    }
  }

  render () {
    const { href, children, className, ...other } = this.props;

    return <a href={href} onClick={this.handleClick} {...other} className={'permalink ' + className}>{children}</a>;
  }

}

Permalink.contextTypes = {
  router: PropTypes.object
};

Permalink.propTypes = {
  className: PropTypes.string,
  href: PropTypes.string.isRequired,
  to: PropTypes.string.isRequired,
  children: PropTypes.node
};

export default Permalink;
