import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from './icon_button';
import { Motion, spring } from 'react-motion';
import { injectIntl } from 'react-intl';

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
    onCloseClicked: React.PropTypes.func,
    intl: React.PropTypes.object.isRequired,
    children: React.PropTypes.node
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    this._listener = e => {
      if (this.props.isVisible && e.key === 'Escape') {
        this.props.onCloseClicked();
      }
    };

    window.addEventListener('keyup', this._listener);
  },

  componentWillUnmount () {
    window.removeEventListener('keyup', this._listener);
  },

  stopPropagation (e) {
    e.stopPropagation();
  },

  render () {
    const { intl, isVisible, onOverlayClicked, onCloseClicked, children } = this.props;

    return (
      <Motion defaultStyle={{ backgroundOpacity: 0, opacity: 0, y: -400 }} style={{ backgroundOpacity: spring(isVisible ? 50 : 0), opacity: isVisible ? spring(200) : 0, y: spring(isVisible ? 0 : -400, { stiffness: 150, damping: 12 }) }}>
        {({ backgroundOpacity, opacity, y }) =>
          <div className='lightbox' style={{...overlayStyle, background: `rgba(0, 0, 0, ${backgroundOpacity / 100})`, display: Math.floor(backgroundOpacity) === 0 ? 'none' : 'flex'}} onClick={onOverlayClicked}>
            <div style={{...dialogStyle, transform: `translateY(${y}px)`, opacity: opacity / 100 }} onClick={this.stopPropagation}>
              <IconButton title={intl.formatMessage({ id: 'lightbox.close', defaultMessage: 'Close' })} icon='times' onClick={onCloseClicked} size={16} style={closeStyle} />
              {children}
            </div>
          </div>
        }
      </Motion>
    );
  }

});

export default injectIntl(Lightbox);
