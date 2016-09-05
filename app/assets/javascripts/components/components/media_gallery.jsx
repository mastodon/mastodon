import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const MediaGallery = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    var children = this.props.media.take(4);
    var size     = children.size;

    children = children.map((attachment, i) => {
      let width  = 50;
      let height = 100;

      if (size == 4 || (size === 3 && i > 0)) {
        height = 50;
      }

      return <a key={attachment.get('id')} href={attachment.get('url')} style={{ boxSizing: 'border-box', position: 'relative', float: 'left', textDecoration: 'none', border: 'none', display: 'block', width: `${width}%`, height: `${height}%`, background: `url(${attachment.get('preview_url')}) no-repeat`, backgroundSize: 'cover', cursor: 'zoom-in' }} />;
    });

    return (
      <div style={{ marginTop: '8px', overflow: 'hidden', width: '100%', height: '110px', boxSizing: 'border-box', padding: '4px' }}>
        {children}
      </div>
    );
  }

});

export default MediaGallery;
