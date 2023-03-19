import Blurhash from 'mastodon/components/blurhash';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import { autoPlayGif, displayMedia, useBlurhash } from 'mastodon/initial_state';
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
  };

  handleMouseEnter = e => {
    if (this.hoverToPlay()) {
      e.target.play();
    }
  };

  handleMouseLeave = e => {
    if (this.hoverToPlay()) {
      e.target.pause();
      e.target.currentTime = 0;
    }
  };

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
  };

  render () {
    const { attachment, displayWidth } = this.props;
    const { visible, loaded } = this.state;

    const width  = `${Math.floor((displayWidth - 4) / 3) - 4}px`;
    const height = width;
    const status = attachment.get('status');

    const translation = status.get('translation');
    const language    = translation ? translation.get('language') : status.get('language');
    const description = translation ? attachment.getIn(['translation', 'description']) : attachment.get('description');
    const spoilerText = translation ? translation.get('spoiler_text') : status.get('spoiler_text');
    const title       = spoilerText || description;

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
            alt={description}
            lang={language}
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
            alt={description}
            lang={language}
            style={{ objectPosition: `${x}% ${y}%` }}
            onLoad={this.handleImageLoad}
          />
        );
      } else if (attachment.get('type') === 'gifv') {
        content = (
          <video
            className='media-gallery__item-gifv-thumbnail'
            aria-label={description}
            title={description}
            lang={language}
            role='application'
            src={attachment.get('url')}
            onMouseEnter={this.handleMouseEnter}
            onMouseLeave={this.handleMouseLeave}
            autoPlay={autoPlayGif}
            playsInline
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
        <a className='media-gallery__item-thumbnail' href={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}`} onClick={this.handleClick} title={title} target='_blank' rel='noopener noreferrer'>
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
