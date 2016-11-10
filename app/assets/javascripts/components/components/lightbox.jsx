import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from './icon_button';
import { Motion, spring } from 'react-motion';

const overlayStyle = {
  position: 'fixed',
  top: '0',
  left: '0',
  width: '100%',
  height: '100%',
  background: 'rgba(0, 0, 0, 0.5)',
  display: 'flex',
  justifyContent: 'center',
  alignContent: 'center',
  flexDirection: 'row',
  zIndex: '9999'
};

const dialogStyle = {
  color: '#282c37',
  boxShadow: '0 0 30px rgba(0, 0, 0, 0.8)',
  margin: 'auto',
  position: 'relative'
};

const closeStyle = {
  position: 'absolute',
  top: '4px',
  right: '4px'
};

const Lightbox = React.createClass({

  propTypes: {
    isVisible: React.PropTypes.bool,
    onOverlayClicked: React.PropTypes.func,
    onCloseClicked: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  render () {
    const { isVisible, onOverlayClicked, onCloseClicked, children } = this.props;

    return (
      <div className='lightbox' style={{...overlayStyle, display: isVisible ? 'flex' : 'none'}} onClick={onOverlayClicked}>
        <Motion defaultStyle={{ y: -200 }} style={{ y: spring(isVisible ? 0 : -200) }}>
          {({ y }) =>
            <div style={{...dialogStyle, transform: `translateY(${y}px)`}}>
              <IconButton title='Close' icon='times' onClick={onCloseClicked} size={16} style={closeStyle} />
              {children}
            </div>
          }
        </Motion>
      </div>
    );
  }

});

export default Lightbox;
