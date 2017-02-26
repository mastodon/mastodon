import { connect } from 'react-redux';
import {
  closeModal,
  decreaseIndexInModal,
  increaseIndexInModal
} from '../../../actions/modal';
import Lightbox from '../../../components/lightbox';
import ImageLoader from 'react-imageloader';
import LoadingIndicator from '../../../components/loading_indicator';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';

const mapStateToProps = state => ({
  media: state.getIn(['modal', 'media']),
  index: state.getIn(['modal', 'index']),
  isVisible: state.getIn(['modal', 'open'])
});

const mapDispatchToProps = dispatch => ({
  onCloseClicked () {
    dispatch(closeModal());
  },

  onOverlayClicked () {
    dispatch(closeModal());
  },

  onNextClicked () {
    dispatch(increaseIndexInModal());
  },

  onPrevClicked () {
    dispatch(decreaseIndexInModal());
  }
});

const imageStyle = {
  display: 'block',
  maxWidth: '80vw',
  maxHeight: '80vh'
};

const loadingStyle = {
  width: '400px',
  paddingBottom: '120px'
};

const preloader = () => (
  <div className='modal-container--preloader' style={loadingStyle}>
    <LoadingIndicator />
  </div>
);

const leftNavStyle = {
  position: 'absolute',
  background: 'rgba(0, 0, 0, 0.5)',
  padding: '30px 15px',
  cursor: 'pointer',
  fontSize: '24px',
  top: '0',
  left: '-61px',
  boxSizing: 'border-box',
  height: '100%',
  display: 'flex',
  alignItems: 'center'
};

const rightNavStyle = {
  position: 'absolute',
  background: 'rgba(0, 0, 0, 0.5)',
  padding: '30px 15px',
  cursor: 'pointer',
  fontSize: '24px',
  top: '0',
  right: '-61px',
  boxSizing: 'border-box',
  height: '100%',
  display: 'flex',
  alignItems: 'center'
};

const Modal = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list,
    index: React.PropTypes.number.isRequired,
    isVisible: React.PropTypes.bool,
    onCloseClicked: React.PropTypes.func,
    onOverlayClicked: React.PropTypes.func,
    onNextClicked: React.PropTypes.func,
    onPrevClicked: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  handleNextClick () {
    this.props.onNextClicked();
  },

  handlePrevClick () {
    this.props.onPrevClicked();
  },

  componentDidMount () {
    this._listener = e => {
      if (!this.props.isVisible) {
        return;
      }

      switch(e.key) {
      case 'ArrowLeft':
        this.props.onPrevClicked();
        break;
      case 'ArrowRight':
        this.props.onNextClicked();
        break;
      }
    };

    window.addEventListener('keyup', this._listener);
  },

  componentWillUnmount () {
    window.removeEventListener('keyup', this._listener);
  },

  render () {
    const { media, index, ...other } = this.props;

    if (!media) {
      return null;
    }

    const url = media.get(index).get('url');

    let leftNav, rightNav;

    leftNav = rightNav = '';

    if (media.size > 1) {
      leftNav  = <div style={leftNavStyle} className='modal-container--nav' onClick={this.handlePrevClick}><i className='fa fa-fw fa-chevron-left' /></div>;
      rightNav = <div style={rightNavStyle} className='modal-container--nav' onClick={this.handleNextClick}><i className='fa fa-fw fa-chevron-right' /></div>;
    }

    return (
      <Lightbox {...other}>
        {leftNav}

        <ImageLoader
          src={url}
          preloader={preloader}
          imgProps={{ style: imageStyle }}
        />

        {rightNav}
      </Lightbox>
    );
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(Modal);
