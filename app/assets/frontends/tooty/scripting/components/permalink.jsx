const Permalink = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    href: React.PropTypes.string.isRequired,
    to: React.PropTypes.string.isRequired,
    children: React.PropTypes.node
  },

  handleClick (e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(this.props.to);
    }
  },

  render () {
    const { href, children, ...other } = this.props;

    return <a href={href} onClick={this.handleClick} {...other}>{children}</a>;
  }

});

export default Permalink;
