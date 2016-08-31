import PureRenderMixin from 'react-addons-pure-render-mixin';

const Avatar = React.createClass({

  propTypes: {
    src: React.PropTypes.string.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ width: '48px', height: '48px', flex: '0 0 auto' }}>
        <img src={this.props.src} width={48} height={48} alt='' style={{ display: 'block', borderRadius: '4px' }} />
      </div>
    );
  }

});

export default Avatar;
