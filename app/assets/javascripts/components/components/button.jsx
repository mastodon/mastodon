import PureRenderMixin from 'react-addons-pure-render-mixin';

const Button = React.createClass({

  propTypes: {
    text: React.PropTypes.node,
    onClick: React.PropTypes.func,
    disabled: React.PropTypes.bool,
    block: React.PropTypes.bool,
    secondary: React.PropTypes.bool,
    size: React.PropTypes.number,
    style: React.PropTypes.object,
    children: React.PropTypes.node
  },

  getDefaultProps () {
    return {
      size: 36
    };
  },

  mixins: [PureRenderMixin],

  handleClick (e) {
    if (!this.props.disabled) {
      this.props.onClick();
    }
  },

  render () {
    const style = {
      fontFamily: 'inherit',
      display: this.props.block ? 'block' : 'inline-block',
      width: this.props.block ? '100%' : 'auto',
      position: 'relative',
      boxSizing: 'border-box',
      textAlign: 'center',
      border: '10px none',
      fontSize: '14px',
      fontWeight: '500',
      letterSpacing: '0',
      padding: `0 ${this.props.size / 2.25}px`,
      height: `${this.props.size}px`,
      cursor: 'pointer',
      lineHeight: `${this.props.size}px`,
      borderRadius: '4px',
      textDecoration: 'none',
      whiteSpace: 'nowrap',
      textOverflow: 'ellipsis',
      overflow: 'hidden'
    };

    return (
      <button className={`button ${this.props.secondary ? 'button-secondary' : ''}`} disabled={this.props.disabled} onClick={this.handleClick} style={{ ...style, ...this.props.style }}>
        {this.props.text || this.props.children}
      </button>
    );
  }

});

export default Button;
