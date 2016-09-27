import PureRenderMixin from 'react-addons-pure-render-mixin';

const Button = React.createClass({

  propTypes: {
    text: React.PropTypes.string,
    onClick: React.PropTypes.func,
    disabled: React.PropTypes.bool,
    block: React.PropTypes.bool,
    secondary: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  handleClick (e) {
    if (!this.props.disabled) {
      this.props.onClick();
    }
  },

  render () {
    const style = {
      fontFamily: 'Roboto',
      display: this.props.block ? 'block' : 'inline-block',
      width: this.props.block ? '100%' : 'auto',
      position: 'relative',
      boxSizing: 'border-box',
      textAlign: 'center',
      border: '10px none',
      color: '#fff',
      fontSize: '14px',
      fontWeight: '500',
      letterSpacing: '0',
      textTransform: 'uppercase',
      padding: '0 16px',
      height: '36px',
      cursor: 'pointer',
      lineHeight: '36px',
      borderRadius: '4px',
      textDecoration: 'none'
    };
    
    return (
      <button className={`button ${this.props.secondary ? 'button-secondary' : ''}`} disabled={this.props.disabled} onClick={this.handleClick} style={style}>
        {this.props.text || this.props.children}
      </button>
    );
  }

});

export default Button;
