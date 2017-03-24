import PureRenderMixin from 'react-addons-pure-render-mixin';
import { Motion, spring } from 'react-motion';
import { FormattedMessage } from 'react-intl';

const UploadArea = React.createClass({

  propTypes: {
    active: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  render () {
    const { active } = this.props;

    return (
      <Motion defaultStyle={{ backgroundOpacity: 0, backgroundScale: 0.95 }} style={{ backgroundOpacity: spring(active ? 1 : 0, { stiffness: 150, damping: 15 }), backgroundScale: spring(active ? 1 : 0.95, { stiffness: 200, damping: 3 }) }}>
        {({ backgroundOpacity, backgroundScale }) =>
          <div className='upload-area' style={{ visibility: active ? 'visible' : 'hidden', opacity: backgroundOpacity }}>
            <div className='upload-area__drop'>
              <div className='upload-area__background' style={{ transform: `translateZ(0) scale(${backgroundScale})` }} />
              <div className='upload-area__content'><FormattedMessage id='upload_area.title' defaultMessage='Drag & drop to upload' /></div>
            </div>
          </div>
        }
      </Motion>
    );
  }

});

export default UploadArea;
