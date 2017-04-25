import PropTypes from 'prop-types';

class Button extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick (e) {
    if (!this.props.disabled) {
      this.props.onClick();
    }
  }

  render () {
    const style = {
      display: this.props.block ? 'block' : 'inline-block',
      width: this.props.block ? '100%' : 'auto',
      padding: `0 ${this.props.size / 2.25}px`,
      height: `${this.props.size}px`,
      lineHeight: `${this.props.size}px`
    };

    return (
      <button className={`button ${this.props.secondary ? 'button-secondary' : ''}`} disabled={this.props.disabled} onClick={this.handleClick} style={{ ...style, ...this.props.style }}>
        {this.props.text || this.props.children}
      </button>
    );
  }

}

Button.propTypes = {
  text: PropTypes.node,
  onClick: PropTypes.func,
  disabled: PropTypes.bool,
  block: PropTypes.bool,
  secondary: PropTypes.bool,
  size: PropTypes.number,
  style: PropTypes.object,
  children: PropTypes.node
};

Button.defaultProps = {
  size: 36
};

export default Button;
