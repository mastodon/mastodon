import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const MediaGallery = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    var children = this.props.media.take(4).map((attachment, i) => {
      return <a key={attachment.get('id')} href={attachment.get('url')} style={{ float: 'left', marginRight: (i % 2 == 0 ? '5px' : '0'), marginBottom: '5px', textDecoration: 'none', border: 'none', display: 'block', width: '142px', height: '110px', background: `url(${attachment.get('preview_url')}) no-repeat`, backgroundSize: 'cover', cursor: 'zoom-in' }} />;
    });

    return (
      <div style={{ marginTop: '8px', overflow: 'hidden', marginBottom: '-5px' }}>
        {children}
      </div>
    );
  }

});

export default MediaGallery;
