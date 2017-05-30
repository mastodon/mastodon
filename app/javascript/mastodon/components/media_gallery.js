import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from './icon_button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { isIOS } from '../is_mobile';

const messages = defineMessages({
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

class Item extends React.PureComponent {

  static propTypes = {
    attachment: ImmutablePropTypes.map.isRequired,
    index: PropTypes.number.isRequired,
    size: PropTypes.number.isRequired,
    onClick: PropTypes.func.isRequired,
    autoPlayGif: PropTypes.bool.isRequired,
  };

  handleClick = (e) => {
    const { index, onClick } = this.props;

    if (e.button === 0) {
      e.preventDefault();
      onClick(index);
    }

    e.stopPropagation();
  }

  render () {
    const { attachment, index, size } = this.props;

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
      thumbnail = (
        <a
          className='media-gallery__item-thumbnail'
          href={attachment.get('remote_url') || attachment.get('url')}
          onClick={this.handleClick}
          target='_blank'
          style={{ backgroundImage: `url(${attachment.get('preview_url')})` }}
        />
      );
    } else if (attachment.get('type') === 'gifv') {
      const autoPlay = !isIOS() && this.props.autoPlayGif;

      thumbnail = (
        <div className={`media-gallery__gifv ${autoPlay ? 'autoplay' : ''}`}>
          <video
            className='media-gallery__item-gifv-thumbnail'
            role='application'
            src={attachment.get('url')}
            onClick={this.handleClick}
            autoPlay={autoPlay}
            loop={true}
            muted={true}
          />

          <span className='media-gallery__gifv__label'>GIF</span>
        </div>
      );
    }

    return (
      <div className='media-gallery__item' key={attachment.get('id')} style={{ left: left, top: top, right: right, bottom: bottom, width: `${width}%`, height: `${height}%` }}>
        {thumbnail}
      </div>
    );
  }

}

class MediaGallery extends React.PureComponent {

  static propTypes = {
    sensitive: PropTypes.bool,
    media: ImmutablePropTypes.list.isRequired,
    height: PropTypes.number.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    autoPlayGif: PropTypes.bool.isRequired,
  };

  state = {
    visible: !this.props.sensitive,
  };

  handleOpen = (e) => {
    this.setState({ visible: !this.state.visible });
  }

  handleClick = (index) => {
    this.props.onOpenMedia(this.props.media, index);
  }

  render () {
    const { media, intl, sensitive } = this.props;

    let children;

    if (!this.state.visible) {
      let warning;

      if (sensitive) {
        warning = <FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' />;
      } else {
        warning = <FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' />;
      }

      children = (
        <div role='button' tabIndex='0' className='media-spoiler' onClick={this.handleOpen}>
          <span className='media-spoiler__warning'>{warning}</span>
          <span className='media-spoiler__trigger'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
        </div>
      );
    } else {
      const size = media.take(4).size;
      children = media.take(4).map((attachment, i) => <Item key={attachment.get('id')} onClick={this.handleClick} attachment={attachment} autoPlayGif={this.props.autoPlayGif} index={i} size={size} />);
    }

    return (
      <div className='media-gallery' style={{ height: `${this.props.height}px` }}>
        <div className={`spoiler-button ${this.state.visible ? 'spoiler-button--visible' : ''}`}>
          <IconButton title={intl.formatMessage(messages.toggle_visible)} icon={this.state.visible ? 'eye' : 'eye-slash'} overlay onClick={this.handleOpen} />
        </div>

        {children}
      </div>
    );
  }

}

export default injectIntl(MediaGallery);
