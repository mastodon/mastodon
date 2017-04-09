import PureRenderMixin from 'react-addons-pure-render-mixin';

const TextIconButton = React.createClass({

  propTypes: {
    label: React.PropTypes.string.isRequired,
    title: React.PropTypes.string,
    active: React.PropTypes.bool,
    onClick: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleClick (e) {
    e.preventDefault();
    this.props.onClick();
  },

  render () {
    const { label, title, active } = this.props;

    return (
      <button title={title} aria-label={title} className={`text-icon-button ${active ? 'active' : ''}`} onClick={this.handleClick}>
        {label}
      </button>
    );
  }

});

export default TextIconButton;
