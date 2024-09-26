import { useState, useCallback } from 'react';

import classNames from 'classnames';

import HeadphonesIcon from '@/material-icons/400-24px/headphones-fill.svg?react';
import MovieIcon from '@/material-icons/400-24px/movie-fill.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';
import { AltTextBadge } from 'mastodon/components/alt_text_badge';
import { Blurhash } from 'mastodon/components/blurhash';
import { Icon } from 'mastodon/components/icon';
import { formatTime } from 'mastodon/features/video';
import { autoPlayGif, displayMedia, useBlurhash } from 'mastodon/initial_state';
import type { Status, MediaAttachment } from 'mastodon/models/status';

export const MediaItem: React.FC<{
  attachment: MediaAttachment;
  onOpenMedia: (arg0: MediaAttachment) => void;
}> = ({ attachment, onOpenMedia }) => {
  const [visible, setVisible] = useState(
    (displayMedia !== 'hide_all' &&
      !attachment.getIn(['status', 'sensitive'])) ||
      displayMedia === 'show_all',
  );
  const [loaded, setLoaded] = useState(false);

  const handleImageLoad = useCallback(() => {
    setLoaded(true);
  }, [setLoaded]);

  const handleMouseEnter = useCallback(
    (e: React.MouseEvent<HTMLVideoElement>) => {
      if (e.target instanceof HTMLVideoElement) {
        void e.target.play();
      }
    },
    [],
  );

  const handleMouseLeave = useCallback(
    (e: React.MouseEvent<HTMLVideoElement>) => {
      if (e.target instanceof HTMLVideoElement) {
        e.target.pause();
        e.target.currentTime = 0;
      }
    },
    [],
  );

  const handleClick = useCallback(
    (e: React.MouseEvent<HTMLAnchorElement>) => {
      if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
        e.preventDefault();

        if (visible) {
          onOpenMedia(attachment);
        } else {
          setVisible(true);
        }
      }
    },
    [attachment, visible, onOpenMedia, setVisible],
  );

  const status = attachment.get('status') as Status;
  const description = (attachment.getIn(['translation', 'description']) ||
    attachment.get('description')) as string | undefined;
  const previewUrl = attachment.get('preview_url') as string;
  const fullUrl = attachment.get('url') as string;
  const avatarUrl = status.getIn(['account', 'avatar_static']) as string;
  const lang = status.get('language') as string;
  const blurhash = attachment.get('blurhash') as string;
  const statusId = status.get('id') as string;
  const acct = status.getIn(['account', 'acct']) as string;
  const type = attachment.get('type') as string;

  let thumbnail;

  const badges = [];

  if (description && description.length > 0) {
    badges.push(<AltTextBadge key='alt' description={description} />);
  }

  if (!visible) {
    thumbnail = (
      <div className='media-gallery__item__overlay'>
        <Icon id='eye-slash' icon={VisibilityOffIcon} />
      </div>
    );
  } else if (type === 'audio') {
    thumbnail = (
      <>
        <img
          src={previewUrl || avatarUrl}
          alt={description}
          title={description}
          lang={lang}
          onLoad={handleImageLoad}
        />

        <div className='media-gallery__item__overlay media-gallery__item__overlay--corner'>
          <Icon id='music' icon={HeadphonesIcon} />
        </div>
      </>
    );
  } else if (type === 'image') {
    const focusX = (attachment.getIn(['meta', 'focus', 'x']) || 0) as number;
    const focusY = (attachment.getIn(['meta', 'focus', 'y']) || 0) as number;
    const x = (focusX / 2 + 0.5) * 100;
    const y = (focusY / -2 + 0.5) * 100;

    thumbnail = (
      <img
        src={previewUrl}
        alt={description}
        title={description}
        lang={lang}
        style={{ objectPosition: `${x}% ${y}%` }}
        onLoad={handleImageLoad}
      />
    );
  } else if (['video', 'gifv'].includes(type)) {
    const duration = attachment.getIn([
      'meta',
      'original',
      'duration',
    ]) as number;

    thumbnail = (
      <div className='media-gallery__gifv'>
        <video
          className='media-gallery__item-gifv-thumbnail'
          aria-label={description}
          title={description}
          lang={lang}
          src={fullUrl}
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
          onLoadedData={handleImageLoad}
          autoPlay={autoPlayGif}
          playsInline
          loop
          muted
        />

        {type === 'video' && (
          <div className='media-gallery__item__overlay media-gallery__item__overlay--corner'>
            <Icon id='play' icon={MovieIcon} />
          </div>
        )}
      </div>
    );

    if (type === 'gifv') {
      badges.push(
        <span
          key='gif'
          className='media-gallery__alt__label media-gallery__alt__label--non-interactive'
        >
          GIF
        </span>,
      );
    } else {
      badges.push(
        <span
          key='video'
          className='media-gallery__alt__label media-gallery__alt__label--non-interactive'
        >
          {formatTime(Math.floor(duration))}
        </span>,
      );
    }
  }

  return (
    <div className='media-gallery__item media-gallery__item--square'>
      <Blurhash
        hash={blurhash}
        className={classNames('media-gallery__preview', {
          'media-gallery__preview--hidden': visible && loaded,
        })}
        dummy={!useBlurhash}
      />

      <a
        className='media-gallery__item-thumbnail'
        href={`/@${acct}/${statusId}`}
        onClick={handleClick}
        target='_blank'
        rel='noopener noreferrer'
      >
        {thumbnail}
      </a>

      {badges.length > 0 && (
        <div className='media-gallery__item__badges'>{badges}</div>
      )}
    </div>
  );
};
