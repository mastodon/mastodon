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
      let width       = 142;
      let height      = 110;
      let marginRight = 0;

      if (size == 4 || (size === 3 && i > 0)) {
        height = 52.5;
      }

      if ((size === 3 && i === 0) || (size === 4 && i % 2 === 0)) {
        marginRight = 5;
      }

      return <a key={attachment.get('id')} href={attachment.get('url')} style={{ position: 'relative', float: 'left', marginRight: `${marginRight}px`, marginBottom: '5px', textDecoration: 'none', border: 'none', display: 'block', width: `${width}px`, height: `${height}px`, background: `url(${attachment.get('preview_url')}) no-repeat`, backgroundSize: 'cover', cursor: 'zoom-in' }} />;
    });

    return (
      <div style={{ marginTop: '8px', overflow: 'hidden', marginBottom: '-5px' }}>
        {children}
      </div>
    );
  }

});

export default MediaGallery;
