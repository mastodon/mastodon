import Blurhash from 'mastodon/components/blurhash';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import { autoPlayGif, displayMedia, useBlurhash } from 'mastodon/initial_state';
import { isIOS } from 'mastodon/is_mobile';
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class MediaItem extends ImmutablePureComponent {

  static propTypes = {
    attachment: ImmutablePropTypes.map.isRequired,
    displayWidth: PropTypes.number.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
  };

  state = {
    visible: displayMedia !== 'hide_all' && !this.props.attachment.getIn(['status', 'sensitive']) || displayMedia === 'show_all',
    loaded: false,
  };

  handleImageLoad = () => {
    this.setState({ loaded: true });
  }

  handleMouseEnter = e => {
    if (this.hoverToPlay()) {
      e.target.play();
    }
  }

  handleMouseLeave = e => {
    if (this.hoverToPlay()) {
      e.target.pause();
      e.target.currentTime = 0;
    }
  }

  hoverToPlay () {
    return !autoPlayGif && ['gifv', 'video'].indexOf(this.props.attachment.get('type')) !== -1;
  }

  handleClick = e => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();

      if (this.state.visible) {
        this.props.onOpenMedia(this.props.attachment);
      } else {
        this.setState({ visible: true });
      }
    }
  }

  render () {
    const { attachment, displayWidth } = this.props;
    const { visible, loaded } = this.state;

    const width  = `${Math.floor((displayWidth - 4) / 3) - 4}px`;
    const height = width;
    const status = attachment.get('status');
    const title  = status.get('spoiler_text') || attachment.get('description');

    let thumbnail, label, icon, content;

    if (!visible) {
      icon = (
        <span className='account-gallery__item__icons'>
          <Icon id='eye-slash' />
        </span>
      );
    } else {
      if (['audio', 'video'].includes(attachment.get('type'))) {
        content = (
          <img
            src={attachment.get('preview_url') || attachment.getIn(['account', 'avatar_static'])}
            alt={attachment.get('description')}
            onLoad={this.handleImageLoad}
          />
        );

        if (attachment.get('type') === 'audio') {
          label = <Icon id='music' />;
        } else {
          label = <Icon id='play' />;
        }
      } else if (attachment.get('type') === 'image') {
        const focusX = attachment.getIn(['meta', 'focus', 'x']) || 0;
        const focusY = attachment.getIn(['meta', 'focus', 'y']) || 0;
        const x      = ((focusX /  2) + .5) * 100;
        const y      = ((focusY / -2) + .5) * 100;

        content = (
          <img
            src={attachment.get('preview_url')}
            alt={attachment.get('description')}
            style={{ objectPosition: `${x}% ${y}%` }}
            onLoad={this.handleImageLoad}
          />
        );
      } else if (attachment.get('type') === 'gifv') {
        content = (
          <video
            className='media-gallery__item-gifv-thumbnail'
            aria-label={attachment.get('description')}
            role='application'
            src={attachment.get('url')}
            onMouseEnter={this.handleMouseEnter}
            onMouseLeave={this.handleMouseLeave}
            autoPlay={!isIOS() && autoPlayGif}
            loop
            muted
          />
        );

        label = 'GIF';
      }

      thumbnail = (
        <div className='media-gallery__gifv'>
          {content}

          {label && <span className='media-gallery__gifv__label'>{label}</span>}
        </div>
      );
    }

    return (
      <div className='account-gallery__item' style={{ width, height }}>
        <a className='media-gallery__item-thumbnail' href={status.get('url')} onClick={this.handleClick} title={title} target='_blank' rel='noopener noreferrer'>
          <Blurhash
            hash={attachment.get('blurhash')}
            className={classNames('media-gallery__preview', { 'media-gallery__preview--hidden': visible && loaded })}
            dummy={!useBlurhash}
          />

          {visible ? thumbnail : icon}
        </a>
      </div>
    );
  }

}
