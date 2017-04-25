import LoadingIndicator from '../../../components/loading_indicator';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ExtendedVideoPlayer from '../../../components/extended_video_player';
import ImageLoader from 'react-imageloader';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' }
});

class MediaModal extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.state = {
      index: null
    };
    this.handleNextClick = this.handleNextClick.bind(this);
    this.handlePrevClick = this.handlePrevClick.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
  }

  handleNextClick () {
    this.setState({ index: (this.getIndex() + 1) % this.props.media.size});
  }

  handlePrevClick () {
    this.setState({ index: (this.getIndex() - 1) % this.props.media.size});
  }

  handleKeyUp (e) {
    switch(e.key) {
    case 'ArrowLeft':
      this.handlePrevClick();
      break;
    case 'ArrowRight':
      this.handleNextClick();
      break;
    }
  }

  componentDidMount () {
    window.addEventListener('keyup', this.handleKeyUp, false);
  }

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp);
  }

  getIndex () {
    return this.state.index !== null ? this.state.index : this.props.index;
  }

  render () {
    const { media, intl, onClose } = this.props;

    const index = this.getIndex();
    const attachment = media.get(index);
    const url = attachment.get('url');

    let leftNav, rightNav, content;

    leftNav = rightNav = content = '';

    if (media.size > 1) {
      leftNav  = <div role='button' tabIndex='0' className='modal-container__nav modal-container__nav--left' onClick={this.handlePrevClick}><i className='fa fa-fw fa-chevron-left' /></div>;
      rightNav = <div role='button' tabIndex='0' className='modal-container__nav  modal-container__nav--right' onClick={this.handleNextClick}><i className='fa fa-fw fa-chevron-right' /></div>;
    }

    if (attachment.get('type') === 'image') {
      content = <ImageLoader src={url} imgProps={{ style: { display: 'block' } }} />;
    } else if (attachment.get('type') === 'gifv') {
      content = <ExtendedVideoPlayer src={url} muted={true} controls={false} />;
    }

    return (
      <div className='modal-root__modal media-modal'>
        {leftNav}

        <div className='media-modal__content'>
          <IconButton className='media-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} />
          {content}
        </div>

        {rightNav}
      </div>
    );
  }

}

MediaModal.propTypes = {
  media: ImmutablePropTypes.list.isRequired,
  index: PropTypes.number.isRequired,
  onClose: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(MediaModal);
