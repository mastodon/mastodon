import PureRenderMixin from 'react-addons-pure-render-mixin';

const Avatar = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired,
    size: React.PropTypes.number.isRequired,
    style: React.PropTypes.object
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ ...this.props.style, width: `${this.props.size}px`, height: `${this.props.size}px` }}>
        <img src={this.props.src} width={this.props.size} height={this.props.size} alt='' style={{ display: 'block', borderRadius: '4px' }} />
      </div>
    );
  }

});

export default Avatar;
