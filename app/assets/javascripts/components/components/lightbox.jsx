import IconButton from './icon_button';

const overlayStyle = {
  position: 'fixed',
  top: '0',
  left: '0',
  width: '100%',
  height: '100%',
  justifyContent: 'center',
  alignContent: 'center',
  background: 'rgba(0, 0, 0, 0.5)',
  display: 'flex',
  zIndex: '9999'
};

const dialogStyle = {
  color: '#282c37',
  background: '#d9e1e8',
  borderRadius: '4px',
  boxShadow: '0 0 15px rgba(0, 0, 0, 0.4)',
  padding: '10px',
  margin: 'auto',
  position: 'relative'
};

const closeStyle = {
  position: 'absolute',
  top: '4px',
  right: '4px'
};

const Lightbox = ({ isVisible, onOverlayClicked, onCloseClicked, children }) => {
  if (!isVisible) {
    return <div />;
  }

  return (
    <div className='lightbox' style={overlayStyle} onClick={onOverlayClicked}>
      <div style={dialogStyle}>
        <IconButton title='Close' icon='times' onClick={onCloseClicked} size={16} style={closeStyle} />
        {children}
      </div>
    </div>
  );
};

Lightbox.propTypes = {
  isVisible: React.PropTypes.bool,
  onOverlayClicked: React.PropTypes.func,
  onCloseClicked: React.PropTypes.func
};

export default Lightbox;
