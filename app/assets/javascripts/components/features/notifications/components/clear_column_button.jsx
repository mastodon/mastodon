const iconStyle = {
  fontSize: '16px',
  padding: '15px',
  position: 'absolute',
  right: '48px',
  top: '0',
  cursor: 'pointer',
  zIndex: '2'
};

const ClearColumnButton = ({ onClick }) => (
  <div className='column-icon' tabindex='0' style={iconStyle} onClick={onClick}>
    <i className='fa fa-trash' />
  </div>
);

ClearColumnButton.propTypes = {
  onClick: React.PropTypes.func.isRequired
};

export default ClearColumnButton;
