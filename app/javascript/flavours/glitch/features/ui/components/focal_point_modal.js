import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import classNames from 'classnames';
import { changeUploadCompose } from 'flavours/glitch/actions/compose';
import { getPointerPosition } from 'flavours/glitch/features/video';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import IconButton from 'flavours/glitch/components/icon_button';
import Button from 'flavours/glitch/components/button';
import Video from 'flavours/glitch/features/video';
import Audio from 'flavours/glitch/features/audio';
import Textarea from 'react-textarea-autosize';
import UploadProgress from 'flavours/glitch/features/compose/components/upload_progress';
import CharacterCounter from 'flavours/glitch/features/compose/components/character_counter';
import { length } from 'stringz';
import { Tesseract as fetchTesseract } from 'flavours/glitch/util/async-components';
import GIFV from 'flavours/glitch/components/gifv';
import { me } from 'flavours/glitch/util/initial_state';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  apply: { id: 'upload_modal.apply', defaultMessage: 'Apply' },
  placeholder: { id: 'upload_modal.description_placeholder', defaultMessage: 'A quick brown fox jumps over the lazy dog' },
});

const mapStateToProps = (state, { id }) => ({
  media: state.getIn(['compose', 'media_attachments']).find(item => item.get('id') === id),
  account: state.getIn(['accounts', me]),
});

const mapDispatchToProps = (dispatch, { id }) => ({

  onSave: (description, x, y) => {
    dispatch(changeUploadCompose(id, { description, focus: `${x.toFixed(2)},${y.toFixed(2)}` }));
  },

});

const removeExtraLineBreaks = str => str.replace(/\n\n/g, '******')
  .replace(/\n/g, ' ')
  .replace(/\*\*\*\*\*\*/g, '\n\n');

const assetHost = process.env.CDN_HOST || '';

class ImageLoader extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    width: PropTypes.number,
    height: PropTypes.number,
  };

  state = {
    loading: true,
  };

  componentDidMount() {
    const image = new Image();
    image.addEventListener('load', () => this.setState({ loading: false }));
    image.src = this.props.src;
  }

  render () {
    const { loading } = this.state;

    if (loading) {
      return <canvas width={this.props.width} height={this.props.height} />;
    } else {
      return <img {...this.props} alt='' />;
    }
  }

}

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class FocalPointModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    account: ImmutablePropTypes.map.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    x: 0,
    y: 0,
    focusX: 0,
    focusY: 0,
    dragging: false,
    description: '',
    dirty: false,
    progress: 0,
    loading: true,
  };

  componentWillMount () {
    this.updatePositionFromMedia(this.props.media);
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.media.get('id') !== nextProps.media.get('id')) {
      this.updatePositionFromMedia(nextProps.media);
    }
  }

  componentWillUnmount () {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);
  }

  handleMouseDown = e => {
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('mouseup', this.handleMouseUp);

    this.updatePosition(e);
    this.setState({ dragging: true });
  }

  handleTouchStart = e => {
    document.addEventListener('touchmove', this.handleMouseMove);
    document.addEventListener('touchend', this.handleTouchEnd);

    this.updatePosition(e);
    this.setState({ dragging: true });
  }

  handleMouseMove = e => {
    this.updatePosition(e);
  }

  handleMouseUp = () => {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('mouseup', this.handleMouseUp);

    this.setState({ dragging: false });
  }

  handleTouchEnd = () => {
    document.removeEventListener('touchmove', this.handleMouseMove);
    document.removeEventListener('touchend', this.handleTouchEnd);

    this.setState({ dragging: false });
  }

  updatePosition = e => {
    const { x, y } = getPointerPosition(this.node, e);
    const focusX   = (x - .5) *  2;
    const focusY   = (y - .5) * -2;

    this.setState({ x, y, focusX, focusY, dirty: true });
  }

  updatePositionFromMedia = media => {
    const focusX      = media.getIn(['meta', 'focus', 'x']);
    const focusY      = media.getIn(['meta', 'focus', 'y']);
    const description = media.get('description') || '';

    if (focusX && focusY) {
      const x = (focusX /  2) + .5;
      const y = (focusY / -2) + .5;

      this.setState({
        x,
        y,
        focusX,
        focusY,
        description,
        dirty: false,
      });
    } else {
      this.setState({
        x: 0.5,
        y: 0.5,
        focusX: 0,
        focusY: 0,
        description,
        dirty: false,
      });
    }
  }

  handleChange = e => {
    this.setState({ description: e.target.value, dirty: true });
  }

  handleKeyDown = (e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      e.stopPropagation();
      this.setState({ description: e.target.value, dirty: true });
      this.handleSubmit();
    }
  }

  handleSubmit = () => {
    this.props.onSave(this.state.description, this.state.focusX, this.state.focusY);
    this.props.onClose();
  }

  setRef = c => {
    this.node = c;
  }

  handleTextDetection = () => {
    const { media } = this.props;

    this.setState({ detecting: true });

    fetchTesseract().then(({ TesseractWorker }) => {
      const worker = new TesseractWorker({
        workerPath: `${assetHost}/packs/ocr/worker.min.js`,
        corePath: `${assetHost}/packs/ocr/tesseract-core.wasm.js`,
        langPath: `${assetHost}/ocr/lang-data`,
      });

      let media_url = media.get('url');

      if (window.URL && URL.createObjectURL) {
        try {
          media_url = URL.createObjectURL(media.get('file'));
        } catch (error) {
          console.error(error);
        }
      }

      worker.recognize(media_url)
        .progress(({ progress }) => this.setState({ progress }))
        .finally(() => worker.terminate())
        .then(({ text }) => this.setState({ description: removeExtraLineBreaks(text), dirty: true, detecting: false }))
        .catch(() => this.setState({ detecting: false }));
    }).catch(() => this.setState({ detecting: false }));
  }

  render () {
    const { media, intl, account, onClose } = this.props;
    const { x, y, dragging, description, dirty, detecting, progress } = this.state;

    const width  = media.getIn(['meta', 'original', 'width']) || null;
    const height = media.getIn(['meta', 'original', 'height']) || null;
    const focals = ['image', 'gifv'].includes(media.get('type'));

    const previewRatio  = 16/9;
    const previewWidth  = 200;
    const previewHeight = previewWidth / previewRatio;

    let descriptionLabel = null;

    if (media.get('type') === 'audio') {
      descriptionLabel = <FormattedMessage id='upload_form.audio_description' defaultMessage='Describe for people with hearing loss' />;
    } else if (media.get('type') === 'video') {
      descriptionLabel = <FormattedMessage id='upload_form.video_description' defaultMessage='Describe for people with hearing loss or visual impairment' />;
    } else {
      descriptionLabel = <FormattedMessage id='upload_form.description' defaultMessage='Describe for the visually impaired' />;
    }

    return (
      <div className='modal-root__modal report-modal' style={{ maxWidth: 960 }}>
        <div className='report-modal__target'>
          <IconButton className='media-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} />
          <FormattedMessage id='upload_modal.edit_media' defaultMessage='Edit media' />
        </div>

        <div className='report-modal__container'>
          <div className='report-modal__comment'>
            {focals && <p><FormattedMessage id='upload_modal.hint' defaultMessage='Click or drag the circle on the preview to choose the focal point which will always be in view on all thumbnails.' /></p>}

            <label className='setting-text-label' htmlFor='upload-modal__description'>
              {descriptionLabel}
            </label>

            <div className='setting-text__wrapper'>
              <Textarea
                id='upload-modal__description'
                className='setting-text light'
                value={detecting ? '…' : description}
                onChange={this.handleChange}
                onKeyDown={this.handleKeyDown}
                disabled={detecting}
                autoFocus
              />

              <div className='setting-text__modifiers'>
                <UploadProgress progress={progress * 100} active={detecting} icon='file-text-o' message={<FormattedMessage id='upload_modal.analyzing_picture' defaultMessage='Analyzing picture…' />} />
              </div>
            </div>

            <div className='setting-text__toolbar'>
              <button disabled={detecting || media.get('type') !== 'image'} className='link-button' onClick={this.handleTextDetection}><FormattedMessage id='upload_modal.detect_text' defaultMessage='Detect text from picture' /></button>
              <CharacterCounter max={1500} text={detecting ? '' : description} />
            </div>

            <Button disabled={!dirty || detecting || length(description) > 1500} text={intl.formatMessage(messages.apply)} onClick={this.handleSubmit} />
          </div>

          <div className='focal-point-modal__content'>
            {focals && (
              <div className={classNames('focal-point', { dragging })} ref={this.setRef} onMouseDown={this.handleMouseDown} onTouchStart={this.handleTouchStart}>
                {media.get('type') === 'image' && <ImageLoader src={media.get('url')} width={width} height={height} alt='' />}
                {media.get('type') === 'gifv' && <GIFV src={media.get('url')} width={width} height={height} />}

                <div className='focal-point__preview'>
                  <strong><FormattedMessage id='upload_modal.preview_label' defaultMessage='Preview ({ratio})' values={{ ratio: '16:9' }} /></strong>
                  <div style={{ width: previewWidth, height: previewHeight, backgroundImage: `url(${media.get('preview_url')})`, backgroundSize: 'cover', backgroundPosition: `${x * 100}% ${y * 100}%` }} />
                </div>

                <div className='focal-point__reticle' style={{ top: `${y * 100}%`, left: `${x * 100}%` }} />
                <div className='focal-point__overlay' />
              </div>
            )}

            {media.get('type') === 'video' && (
              <Video
                preview={media.get('preview_url')}
                blurhash={media.get('blurhash')}
                src={media.get('url')}
                detailed
                inline
                editable
              />
            )}

            {media.get('type') === 'audio' && (
              <Audio
                src={media.get('url')}
                duration={media.getIn(['meta', 'original', 'duration'], 0)}
                height={150}
                poster={media.get('preview_url') || account.get('avatar_static')}
                blurhash={media.get('blurhash')}
                editable
              />
            )}
          </div>
        </div>
      </div>
    );
  }

}
