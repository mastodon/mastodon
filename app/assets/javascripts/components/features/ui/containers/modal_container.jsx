import { connect }           from 'react-redux';
import { closeModal }        from '../../../actions/modal';
import Lightbox              from '../../../components/lightbox';

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

const imageStyle = {
  display: 'block',
  maxWidth: '100%',
  height: 'auto',
  margin: '0 auto'
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
      <Lightbox {...other}>
        <img src={url} style={imageStyle} />
      </Lightbox>
    );
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(Modal);
