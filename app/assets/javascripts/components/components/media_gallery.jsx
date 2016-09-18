import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const MediaGallery = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list.isRequired,
    height: React.PropTypes.number.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    var children = this.props.media.take(4);
    var size     = children.size;

    children = children.map((attachment, i) => {
      let width  = 50;
      let height = 100;
      let top    = 'auto';
      let left   = 'auto';
      let bottom = 'auto';
      let right  = 'auto';

      if (size === 4 || (size === 3 && i > 0)) {
        height = 50;
      }

      if (size === 2) {
        if (i === 0) {
          right = '2px';
        } else {
          left = '2px';
        }
      } else if (size === 3) {
        if (i === 0) {
          right = '2px';
        } else if (i > 0) {
          left = '2px';
        }

        if (i === 1) {
          bottom = '2px';
        } else if (i > 1) {
          top = '2px';
        }
      } else if (size === 4) {
        if (i === 0 || i === 2) {
          right = '2px';
        }

        if (i === 1 || i === 3) {
          left = '2px';
        }

        if (i < 2) {
          bottom = '2px';
        } else {
          top = '2px';
        }
      }

      return <a key={attachment.get('id')} href={attachment.get('url')} target='_blank' style={{ boxSizing: 'border-box', position: 'relative', left: left, top: top, right: right, bottom: bottom, float: 'left', textDecoration: 'none', border: 'none', display: 'block', width: `${width}%`, height: `${height}%`, background: `url(${attachment.get('preview_url')}) no-repeat center`, backgroundSize: 'cover', cursor: 'zoom-in' }} />;
    });

    return (
      <div style={{ marginTop: '8px', overflow: 'hidden', width: '100%', height: `${this.props.height}px`, boxSizing: 'border-box' }}>
        {children}
      </div>
    );
  }

});

export default MediaGallery;
