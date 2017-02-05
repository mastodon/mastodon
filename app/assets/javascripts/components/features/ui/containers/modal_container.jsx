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
  background: '#373b4a',
  width: '400px',
  paddingBottom: '120px'
};

const preloader = () => (
  <div style={loadingStyle}>
    <LoadingIndicator />
  </div>
);

const leftNavStyle = {
  position: 'absolute',
  background: 'rgba(0, 0, 0, 0.5)',
  padding: '30px 15px',
  cursor: 'pointer',
  color: '#fff',
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
  color: '#fff',
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

  render () {
    const { media, index, ...other } = this.props;

    if (!media) {
      return null;
    }

    const url      = media.get(index).get('url');
    const hasLeft  = index > 0;
    const hasRight = index + 1 < media.size;

    let leftNav, rightNav;

    leftNav = rightNav = '';

    if (hasLeft) {
      leftNav = <div style={leftNavStyle} onClick={this.handlePrevClick}><i className='fa fa-fw fa-chevron-left' /></div>;
    }

    if (hasRight) {
      rightNav = <div style={rightNavStyle} onClick={this.handleNextClick}><i className='fa fa-fw fa-chevron-right' /></div>;
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
