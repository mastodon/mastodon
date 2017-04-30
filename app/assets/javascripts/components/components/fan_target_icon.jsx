import PureRenderMixin from 'react-addons-pure-render-mixin';

const FanTargetIcon = React.createClass({
  propTypes: {
    src: React.PropTypes.string.isRequired,
    size: React.PropTypes.number.isRequired
  },

  render () {
    return (
      <img src={this.props.src} width={this.props.size} height={this.props.size} />
    )
  }
});

export default FanTargetIcon;
