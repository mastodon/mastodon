import { connect }           from 'react-redux';
import { SkyLightStateless } from 'react-skylight';
import { closeModal }        from '../../../actions/modal';

const mapStateToProps = state => ({
  url: state.getIn(['modal', 'url']),
  isVisible: state.getIn(['modal', 'open'])
});

const mapDispatchToProps = dispatch => ({
  onCloseClicked () {
    dispatch(closeModal());
  },

  onOverlayClicked () {
    dispatch(closeModal());
  }
});

const styles = {
  overlayStyles: {

  },

  dialogStyles: {
    width: '600px',
    color: '#282c37',
    fontSize: '16px',
    lineHeight: '37px',
    marginTop: '-300px',
    left: '0',
    right: '0',
    marginLeft: 'auto',
    marginRight: 'auto',
    height: 'auto'
  },

  imageStyle: {
    display: 'block',
    maxWidth: '100%',
    height: 'auto',
    margin: '0 auto'
  }
};

const Modal = React.createClass({

  propTypes: {
    url: React.PropTypes.string,
    isVisible: React.PropTypes.bool,
    onCloseClicked: React.PropTypes.func,
    onOverlayClicked: React.PropTypes.func
  },

  render () {
    const { url, ...other } = this.props;

    return (
      <SkyLightStateless {...other} dialogStyles={styles.dialogStyles} overlayStyles={styles.overlayStyles}>
        <img src={url} style={styles.imageStyle} />
      </SkyLightStateless>
    );
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(Modal);
