import PureRenderMixin from 'react-addons-pure-render-mixin';

const IconButton = React.createClass({

  propTypes: {
    title: React.PropTypes.string.isRequired,
    icon: React.PropTypes.string.isRequired,
    onClick: React.PropTypes.func.isRequired,
    size: React.PropTypes.number,
    active: React.PropTypes.bool
  },

  getDefaultProps () {
    return {
      size: 18,
      active: false
    };
  },

  mixins: [PureRenderMixin],

  handleClick (e) {
    e.preventDefault();
    this.props.onClick();
  },

  render () {
    return (
      <a href='#' title={this.props.title} className={`icon-button ${this.props.active ? 'active' : ''}`} onClick={this.handleClick} style={{ display: 'inline-block', fontSize: `${this.props.size}px`, width: `${this.props.size}px`, height: `${this.props.size}px`, lineHeight: `${this.props.size}px`}}>
        <i className={`fa fa-fw fa-${this.props.icon}`}></i>
      </a>
    );
  }

});

export default IconButton;
