import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { is } from 'immutable';
import IconButton from './icon_button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { isIOS } from 'flavours/glitch/util/is_mobile';
import classNames from 'classnames';
import { autoPlayGif, displayMedia } from 'flavours/glitch/util/initial_state';

const messages = defineMessages({
  hidden: {
    defaultMessage: 'Media hidden',
    id: 'status.media_hidden',
  },
  sensitive: {
    defaultMessage: 'Sensitive',
    id: 'media_gallery.sensitive',
  },
  toggle: {
    defaultMessage: 'Click to view',
    id: 'status.sensitive_toggle',
  },
  toggle_visible: {
    defaultMessage: 'Toggle visibility',
    id: 'media_gallery.toggle_visible',
  },
  warning: {
    defaultMessage: 'Sensitive content',
    id: 'status.sensitive_warning',
  },
});

class Item extends React.PureComponent {

  static propTypes = {
    attachment: ImmutablePropTypes.map.isRequired,
    standalone: PropTypes.bool,
    index: PropTypes.number.isRequired,
    size: PropTypes.number.isRequired,
    letterbox: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    displayWidth: PropTypes.number,
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

    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      if (this.hoverToPlay()) {
        e.target.pause();
        e.target.currentTime = 0;
      }
      e.preventDefault();
      onClick(index);
    }

    e.stopPropagation();
  }

  handleMouseDown = (e) => {
    e.preventDefault();
    e.stopPropagation();
  }

  render () {
    const { attachment, index, size, standalone, letterbox, displayWidth } = this.props;

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

      const hasSize = typeof originalWidth === 'number' && typeof previewWidth === 'number';

      const srcSet = hasSize ? `${originalUrl} ${originalWidth}w, ${previewUrl} ${previewWidth}w` : null;
      const sizes  = hasSize && (displayWidth > 0) ? `${displayWidth * (width / 100)}px` : null;

      const focusX = attachment.getIn(['meta', 'focus', 'x']) || 0;
      const focusY = attachment.getIn(['meta', 'focus', 'y']) || 0;
      const x      = ((focusX /  2) + .5) * 100;
      const y      = ((focusY / -2) + .5) * 100;

      thumbnail = (
        <a
          className='media-gallery__item-thumbnail'
          href={attachment.get('remote_url') || originalUrl}
          onClick={this.handleClick}
          target='_blank'
        >
          <img
            className={letterbox ? 'letterbox' : null}
            src={previewUrl}
            srcSet={srcSet}
            sizes={sizes}
            alt={attachment.get('description')}
            title={attachment.get('description')}
            style={{ objectPosition: letterbox ? null : `${x}% ${y}%` }}
          />
        </a>
      );
    } else if (attachment.get('type') === 'gifv') {
      const autoPlay = !isIOS() && autoPlayGif;

      thumbnail = (
        <div className={classNames('media-gallery__gifv', { autoplay: autoPlay })}>
          <video
            className={`media-gallery__item-gifv-thumbnail${letterbox ? ' letterbox' : ''}`}
            aria-label={attachment.get('description')}
            title={attachment.get('description')}
            role='application'
            src={attachment.get('url')}
            onClick={this.handleClick}
            onMouseEnter={this.handleMouseEnter}
            onMouseLeave={this.handleMouseLeave}
            onMouseDown={this.handleMouseDown}
            autoPlay={autoPlay}
            loop
            muted
          />

          <span className='media-gallery__gifv__label'>GIF</span>
        </div>
      );
    }

    return (
      <div className={classNames('media-gallery__item', { standalone, letterbox })} key={attachment.get('id')} style={{ left: left, top: top, right: right, bottom: bottom, width: `${width}%`, height: `${height}%` }}>
        {thumbnail}
      </div>
    );
  }

}

@injectIntl
export default class MediaGallery extends React.PureComponent {

  static propTypes = {
    sensitive: PropTypes.bool,
    revealed: PropTypes.bool,
    standalone: PropTypes.bool,
    letterbox: PropTypes.bool,
    fullwidth: PropTypes.bool,
    hidden: PropTypes.bool,
    media: ImmutablePropTypes.list.isRequired,
    size: PropTypes.object,
    onOpenMedia: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  static defaultProps = {
    standalone: false,
  };

  state = {
    visible: this.props.revealed === undefined ? (displayMedia !== 'hide_all' && !this.props.sensitive || displayMedia === 'show_all') : this.props.revealed,
  };

  componentWillReceiveProps (nextProps) {
    if (!is(nextProps.media, this.props.media)) {
      this.setState({ visible: nextProps.revealed === undefined ? (displayMedia !== 'hide_all' && !nextProps.sensitive || displayMedia === 'show_all') : nextProps.revealed });
    }
  }

  componentDidUpdate (prevProps) {
    if (this.node && this.node.offsetWidth && this.node.offsetWidth != this.state.width) {
      this.setState({
        width: this.node.offsetWidth,
      });
    }
  }

  handleOpen = () => {
    this.setState({ visible: !this.state.visible });
  }

  handleClick = (index) => {
    this.props.onOpenMedia(this.props.media, index);
  }

  handleRef = (node) => {
    this.node = node;
    if (node && node.offsetWidth && node.offsetWidth != this.state.width) {
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
    const { media, intl, sensitive, letterbox, fullwidth } = this.props;
    const { width, visible } = this.state;
    const size = media.take(4).size;

    let children;

    const style = {};

    const computedClass = classNames('media-gallery', { 'full-width': fullwidth });

    if (this.isStandaloneEligible() && width) {
      style.height = width / this.props.media.getIn([0, 'meta', 'small', 'aspect']);
    } else if (width) {
      style.height = width / (16/9);
    } else {
      return (<div className={computedClass} ref={this.handleRef}></div>);
    }

    if (!visible) {
      let warning = <FormattedMessage {...(sensitive ? messages.warning : messages.hidden)} />;

      children = (
        <button className='media-spoiler' type='button' onClick={this.handleOpen}>
          <span className='media-spoiler__warning'>{warning}</span>
          <span className='media-spoiler__trigger'><FormattedMessage {...messages.toggle} /></span>
        </button>
      );
    } else {
      if (this.isStandaloneEligible()) {
        children = <Item standalone attachment={media.get(0)} onClick={this.handleClick} displayWidth={width} />;
      } else {
        children = media.take(4).map((attachment, i) => <Item key={attachment.get('id')} onClick={this.handleClick} attachment={attachment} index={i} size={size} letterbox={letterbox} displayWidth={width} />);
      }
    }

    return (
      <div className={computedClass} style={style} ref={this.handleRef}>
        {visible ? (
          <div className='sensitive-info'>
            <IconButton
              icon='eye'
              onClick={this.handleOpen}
              overlay
              title={intl.formatMessage(messages.toggle_visible)}
            />
            {sensitive ? (
              <span className='sensitive-marker'>
                <FormattedMessage {...messages.sensitive} />
              </span>
            ) : null}
          </div>
        ) : null}

        {children}
      </div>
    );
  }

}
