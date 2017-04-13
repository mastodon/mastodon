import LoadingIndicator from '../../../components/loading_indicator';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ExtendedVideoPlayer from '../../../components/extended_video_player';
import ImageLoader from 'react-imageloader';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' }
});

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

const closeStyle = {
  position: 'absolute',
  top: '4px',
  right: '4px'
};

const MediaModal = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.list.isRequired,
    index: React.PropTypes.number.isRequired,
    onClose: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  getInitialState () {
    return {
      index: null
    };
  },

  mixins: [PureRenderMixin],

  handleNextClick () {
    this.setState({ index: (this.getIndex() + 1) % this.props.media.size});
  },

  handlePrevClick () {
    this.setState({ index: (this.getIndex() - 1) % this.props.media.size});
  },

  handleKeyUp (e) {
    switch(e.key) {
    case 'ArrowLeft':
      this.handlePrevClick();
      break;
    case 'ArrowRight':
      this.handleNextClick();
      break;
    }
  },

  componentDidMount () {
    window.addEventListener('keyup', this.handleKeyUp, false);
  },

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp);
  },

  getIndex () {
    return this.state.index !== null ? this.state.index : this.props.index;
  },

  render () {
    const { media, intl, onClose } = this.props;

    const index = this.getIndex();
    const attachment = media.get(index);
    const url = attachment.get('url');

    let leftNav, rightNav, content;

    leftNav = rightNav = content = '';

    if (media.size > 1) {
      leftNav  = <div role='button' tabIndex='0' style={leftNavStyle} className='modal-container__nav' onClick={this.handlePrevClick}><i className='fa fa-fw fa-chevron-left' /></div>;
      rightNav = <div role='button' tabIndex='0' style={rightNavStyle} className='modal-container__nav' onClick={this.handleNextClick}><i className='fa fa-fw fa-chevron-right' /></div>;
    }

    if (attachment.get('type') === 'image') {
      content = <ImageLoader src={url} imgProps={{ style: { display: 'block' } }} />;
    } else if (attachment.get('type') === 'gifv') {
      content = <ExtendedVideoPlayer src={url} muted={true} controls={false} />;
    }

    return (
      <div className='modal-root__modal media-modal'>
        {leftNav}

        <div>
          <IconButton title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} style={closeStyle} />
          {content}
        </div>

        {rightNav}
      </div>
    );
  }

});

export default injectIntl(MediaModal);
