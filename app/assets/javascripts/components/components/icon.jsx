import PureRenderMixin from 'react-addons-pure-render-mixin';

const Icon = React.createClass({

  propTypes: {
    icon: React.PropTypes.string.isRequired,
    active: React.PropTypes.bool,
    fixedWidth: React.PropTypes.bool,
    className: React.PropTypes.string,
    iconPrefix: React.PropTypes.string,
    ariaLabel: React.PropTypes.string,
    style: React.PropTypes.object
  },

  getDefaultProps () {
    return {
      active: false,
      fixedWidth: false,
      iconPrefix: 'fa'
    };
  },

  mixins: [PureRenderMixin],

  render () {
    const active = (this.props.active) ? ' active' : '',
    fixedWidth = (this.props.fixedWidth) ? ` ${this.props.iconPrefix}-fw` : '';

    return (
      <i className={`${this.props.iconPrefix}${fixedWidth} ${this.props.iconPrefix}-${this.props.icon}${active}`} {...props} />
    );
  }

});

export default Icon;
