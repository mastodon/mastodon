//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';

//  Mastodon imports  //
import { isIOS } from '../../../../mastodon/is_mobile';

export default class StatusGalleryItem extends React.PureComponent {

  static propTypes = {
    attachment: ImmutablePropTypes.map.isRequired,
    index: PropTypes.number.isRequired,
    size: PropTypes.number.isRequired,
    letterbox: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    autoPlayGif: PropTypes.bool.isRequired,
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
    const { attachment, autoPlayGif } = this.props;
    return !autoPlayGif && attachment.get('type') === 'gifv';
  }

  handleClick = (e) => {
    const { index, onClick } = this.props;

    if (e.button === 0) {
      e.preventDefault();
      onClick(index);
    }

    e.stopPropagation();
  }

  render () {
    const { attachment, index, size, letterbox } = this.props;

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
      const previewUrl = attachment.get('preview_url');
      const previewWidth = attachment.getIn(['meta', 'small', 'width']);

      const originalUrl = attachment.get('url');
      const originalWidth = attachment.getIn(['meta', 'original', 'width']);

      const srcSet = `${originalUrl} ${originalWidth}w, ${previewUrl} ${previewWidth}w`;
      const sizes = `(min-width: 1025px) ${320 * (width / 100)}px, ${width}vw`;

      thumbnail = (
        <a
          className='media-gallery__item-thumbnail'
          href={attachment.get('remote_url') || originalUrl}
          onClick={this.handleClick}
          target='_blank'
        >
          <img
            className={letterbox ? 'letterbox' : ''}
            src={previewUrl} srcSet={srcSet}
            sizes={sizes}
            alt={attachment.get('description')}
            title={attachment.get('description')}
          />
        </a>
      );
    } else if (attachment.get('type') === 'gifv') {
      const autoPlay = !isIOS() && this.props.autoPlayGif;

      thumbnail = (
        <div className={`media-gallery__gifv ${autoPlay ? 'autoplay' : ''}`}>
          <video
            className={`media-gallery__item-gifv-thumbnail${letterbox ? ' letterbox' : ''}`}
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
      <div className='media-gallery__item' key={attachment.get('id')} style={{ left: left, top: top, right: right, bottom: bottom, width: `${width}%`, height: `${height}%` }}>
        {thumbnail}
      </div>
    );
  }

}
