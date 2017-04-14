import PureRenderMixin from 'react-addons-pure-render-mixin';
import { Motion, spring } from 'react-motion';

const IconButton = React.createClass({

  propTypes: {
    title: React.PropTypes.string.isRequired,
    icon: React.PropTypes.string.isRequired,
    onClick: React.PropTypes.func,
    size: React.PropTypes.number,
    active: React.PropTypes.bool,
    style: React.PropTypes.object,
    activeStyle: React.PropTypes.object,
    disabled: React.PropTypes.bool,
    inverted: React.PropTypes.bool,
    animate: React.PropTypes.bool,
    overlay: React.PropTypes.bool
  },

  getDefaultProps () {
    return {
      size: 18,
      active: false,
      disabled: false,
      animate: false,
      overlay: false
    };
  },

  mixins: [PureRenderMixin],

  handleClick (e) {
    e.preventDefault();

    if (!this.props.disabled) {
      this.props.onClick(e);
    }
  },

  render () {
    let style = {
      fontSize: `${this.props.size}px`,
      width: `${this.props.size * 1.28571429}px`,
      height: `${this.props.size * 1.28571429}px`,
      lineHeight: `${this.props.size}px`,
      ...this.props.style
    };

    if (this.props.active) {
      style = { ...style, ...this.props.activeStyle };
    }

    const classes = ['icon-button'];

    if (this.props.active) {
      classes.push('active');
    }

    if (this.props.disabled) {
      classes.push('disabled');
    }

    if (this.props.inverted) {
      classes.push('inverted');
    }

    if (this.props.overlay) {
      classes.push('overlayed');
    }

    return (
      <Motion defaultStyle={{ rotate: this.props.active ? -360 : 0 }} style={{ rotate: this.props.animate ? spring(this.props.active ? -360 : 0, { stiffness: 120, damping: 7 }) : 0 }}>
        {({ rotate }) =>
          <button
            aria-label={this.props.title}
            title={this.props.title}
            className={classes.join(' ')}
            onClick={this.handleClick}
            style={style}>
            <i style={{ transform: `rotate(${rotate}deg)` }} className={`fa fa-fw fa-${this.props.icon}`} aria-hidden='true' />
          </button>
        }
      </Motion>
    );
  }

});

export default IconButton;
