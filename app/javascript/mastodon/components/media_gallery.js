import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { is } from 'immutable';
import IconButton from './icon_button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { isIOS } from '../is_mobile';
import classNames from 'classnames';
import { autoPlayGif, displaySensitiveMedia } from '../initial_state';

const messages = defineMessages({
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

const shiftToPoint = (containerToImageRatio, containerSize, imageSize, focusSize, toMinus) => {
  const containerCenter = Math.floor(containerSize / 2);
  const focusFactor     = (focusSize + 1) / 2;
  const scaledImage     = Math.floor(imageSize / containerToImageRatio);

  let focus = Math.floor(focusFactor * scaledImage);

  if (toMinus) focus = scaledImage - focus;

  let focusOffset = focus - containerCenter;

  const remainder = scaledImage - focus;
  const containerRemainder = containerSize - containerCenter;

  if (remainder < containerRemainder) focusOffset -= containerRemainder - remainder;
  if (focusOffset < 0) focusOffset = 0;

  return (focusOffset * -100 / containerSize) + '%';
};

class Item extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    attachment: ImmutablePropTypes.map.isRequired,
    standalone: PropTypes.bool,
    index: PropTypes.number.isRequired,
    size: PropTypes.number.isRequired,
    onClick: PropTypes.func.isRequired,
    containerWidth: PropTypes.number,
    containerHeight: PropTypes.number,
  };

  static defaultProps = {
    standalone: false,
    index: 0,
    size: 1,
  };

  handleMouseEnter = (e) => {
    if (this.hoverToPlay()) {
      e.target.play();
    }
  }

  handleMouseLeave = (e) => {
    if (this.hoverToPlay()) {
      e.target.pause();
      e.target.currentTime = 0;
    }
  }

  hoverToPlay () {
    const { attachment } = this.props;
    return !autoPlayGif && attachment.get('type') === 'gifv';
  }

  handleClick = (e) => {
    const { index, onClick } = this.props;

    if (this.context.router && e.button === 0) {
      e.preventDefault();
      onClick(index);
    }

    e.stopPropagation();
  }

  render () {
    const { attachment, index, size, standalone, containerWidth, containerHeight } = this.props;

    let width  = 50;
    let height = 100;
    let top    = 'auto';
    let left   = 'auto';
    let bottom = 'auto';
    let right  = 'auto';

    if (size === 1) {
      width = 100;
    }

    if (size === 4 || (size === 3 && index > 0)) {
      height = 50;
    }

    if (size === 2) {
      if (index === 0) {
        right = '2px';
      } else {
        left = '2px';
      }
    } else if (size === 3) {
      if (index === 0) {
        right = '2px';
      } else if (index > 0) {
        left = '2px';
      }

      if (index === 1) {
        bottom = '2px';
      } else if (index > 1) {
        top = '2px';
      }
    } else if (size === 4) {
      if (index === 0 || index === 2) {
        right = '2px';
      }

      if (index === 1 || index === 3) {
        left = '2px';
      }

      if (index < 2) {
        bottom = '2px';
      } else {
        top = '2px';
      }
    }

    let thumbnail = '';

    if (attachment.get('type') === 'image') {
      const previewUrl   = attachment.get('preview_url');
      const previewWidth = attachment.getIn(['meta', 'small', 'width']);

      const originalUrl    = attachment.get('url');
      const originalWidth  = attachment.getIn(['meta', 'original', 'width']);
      const originalHeight = attachment.getIn(['meta', 'original', 'height']);

      const hasSize = typeof originalWidth === 'number' && typeof previewWidth === 'number';

      const srcSet = hasSize ? `${originalUrl} ${originalWidth}w, ${previewUrl} ${previewWidth}w` : null;
      const sizes  = hasSize ? `(min-width: 1025px) ${320 * (width / 100)}px, ${width}vw` : null;

      const focusX     = attachment.getIn(['meta', 'focus', 'x']);
      const focusY     = attachment.getIn(['meta', 'focus', 'y']);
      const imageStyle = {};

      if (originalWidth && originalHeight && containerWidth && containerHeight && focusX && focusY) {
        const widthRatio  = originalWidth / (containerWidth * (width / 100));
        const heightRatio = originalHeight / (containerHeight * (height / 100));

        let hShift = 0;
        let vShift = 0;

        if (widthRatio > heightRatio) {
          hShift = shiftToPoint(heightRatio, (containerWidth * (width / 100)), originalWidth, focusX);
        } else if(widthRatio < heightRatio) {
          vShift = shiftToPoint(widthRatio, (containerHeight * (height / 100)), originalHeight, focusY, true);
        }

        if (originalWidth > originalHeight) {
          imageStyle.height   = '100%';
          imageStyle.width    = 'auto';
          imageStyle.minWidth = '100%';
        } else {
          imageStyle.height    = 'auto';
          imageStyle.width     = '100%';
          imageStyle.minHeight = '100%';
        }

        imageStyle.top  = vShift;
        imageStyle.left = hShift;
      } else {
        imageStyle.height = '100%';
      }

      thumbnail = (
        <a
          className='media-gallery__item-thumbnail'
          href={attachment.get('remote_url') || originalUrl}
          onClick={this.handleClick}
          target='_blank'
        >
          <img
            src={previewUrl}
            srcSet={srcSet}
            sizes={sizes}
            alt={attachment.get('description')}
            title={attachment.get('description')}
            style={imageStyle}
          />
        </a>
      );
    } else if (attachment.get('type') === 'gifv') {
      const autoPlay = !isIOS() && autoPlayGif;

      thumbnail = (
        <div className={classNames('media-gallery__gifv', { autoplay: autoPlay })}>
          <video
            className='media-gallery__item-gifv-thumbnail'
            aria-label={attachment.get('description')}
            role='application'
            src={attachment.get('url')}
            onClick={this.handleClick}
            onMouseEnter={this.handleMouseEnter}
            onMouseLeave={this.handleMouseLeave}
            autoPlay={autoPlay}
            loop
            muted
          />

          <span className='media-gallery__gifv__label'>GIF</span>
        </div>
      );
    }

    return (
      <div className={classNames('media-gallery__item', { standalone })} key={attachment.get('id')} style={{ left: left, top: top, right: right, bottom: bottom, width: `${width}%`, height: `${height}%` }}>
        {thumbnail}
      </div>
    );
  }

}

@injectIntl
export default class MediaGallery extends React.PureComponent {

  static propTypes = {
    sensitive: PropTypes.bool,
    standalone: PropTypes.bool,
    media: ImmutablePropTypes.list.isRequired,
    size: PropTypes.object,
    height: PropTypes.number.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  static defaultProps = {
    standalone: false,
  };

  state = {
    visible: !this.props.sensitive || displaySensitiveMedia,
  };

  componentWillReceiveProps (nextProps) {
    if (!is(nextProps.media, this.props.media)) {
      this.setState({ visible: !nextProps.sensitive });
    }
  }

  handleOpen = () => {
    this.setState({ visible: !this.state.visible });
  }

  handleClick = (index) => {
    this.props.onOpenMedia(this.props.media, index);
  }

  handleRef = (node) => {
    if (node /*&& this.isStandaloneEligible()*/) {
      // offsetWidth triggers a layout, so only calculate when we need to
      this.setState({
        width: node.offsetWidth,
      });
    }
  }

  isStandaloneEligible() {
    const { media, standalone } = this.props;
    return standalone && media.size === 1 && media.getIn([0, 'meta', 'small', 'aspect']);
  }

  render () {
    const { media, intl, sensitive, height } = this.props;
    const { width, visible } = this.state;

    let children;

    const style = {};

    if (this.isStandaloneEligible()) {
      if (width) {
        style.height = width / this.props.media.getIn([0, 'meta', 'small', 'aspect']);
      }
    } else if (width) {
      style.height = width / (16/9);
    } else {
      style.height = height;
    }

    if (!visible) {
      let warning;

      if (sensitive) {
        warning = <FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' />;
      } else {
        warning = <FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' />;
      }

      children = (
        <button type='button' className='media-spoiler' onClick={this.handleOpen} style={style} ref={this.handleRef}>
          <span className='media-spoiler__warning'>{warning}</span>
          <span className='media-spoiler__trigger'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
        </button>
      );
    } else {
      const size = media.take(4).size;

      if (this.isStandaloneEligible()) {
        children = <Item standalone onClick={this.handleClick} attachment={media.get(0)} />;
      } else {
        children = media.take(4).map((attachment, i) => <Item key={attachment.get('id')} onClick={this.handleClick} attachment={attachment} index={i} size={size} containerWidth={width} containerHeight={style.height} />);
      }
    }

    return (
      <div className='media-gallery' style={style} ref={this.handleRef}>
        <div className={classNames('spoiler-button', { 'spoiler-button--visible': visible })}>
          <IconButton title={intl.formatMessage(messages.toggle_visible)} icon={visible ? 'eye' : 'eye-slash'} overlay onClick={this.handleOpen} />
        </div>

        {children}
      </div>
    );
  }

}
