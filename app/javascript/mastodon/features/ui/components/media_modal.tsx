import { forwardRef, useCallback, useEffect, useMemo, useState } from 'react';
import type { RefCallback, FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { List as ImmutableList } from 'immutable';

import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import type { MediaAttachment } from '@/mastodon/models/status';
import ChevronLeftIcon from '@/material-icons/400-24px/chevron_left.svg?react';
import ChevronRightIcon from '@/material-icons/400-24px/chevron_right.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import FitScreenIcon from '@/material-icons/400-24px/fit_screen.svg?react';
import ActualSizeIcon from '@/svg-icons/actual_size.svg?react';
import type { RGB } from 'mastodon/blurhash';
import { getAverageFromBlurhash } from 'mastodon/blurhash';
import { GIFV } from 'mastodon/components/gifv';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import { Footer } from 'mastodon/features/picture_in_picture/components/footer';
import { Video } from 'mastodon/features/video';

import { ZoomableImage } from './zoomable_image';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
  zoomIn: { id: 'lightbox.zoom_in', defaultMessage: 'Zoom to actual size' },
  zoomOut: { id: 'lightbox.zoom_out', defaultMessage: 'Zoom to fit' },
});

interface MediaModalProps {
  media: ImmutableList<MediaAttachment>;
  statusId?: string;
  lang?: string;
  index: number;
  onClose: () => void;
  onChangeBackgroundColor: (color: RGB | null) => void;
  currentTime?: number;
  autoPlay?: boolean;
  volume?: number;
}

const MIN_SWIPE_DISTANCE = 400;

export const MediaModal: FC<MediaModalProps> = forwardRef<
  HTMLDivElement,
  MediaModalProps
>(
  (
    {
      media,
      onClose,
      index: startIndex,
      lang,
      currentTime,
      autoPlay,
      volume,
      statusId,
      onChangeBackgroundColor,
    },
    // eslint-disable-next-line @typescript-eslint/no-unused-vars -- _ref is required to keep the ref forwarding working
    _ref,
  ) => {
    const [index, setIndex] = useState(startIndex);
    const [zoomedIn, setZoomedIn] = useState(false);
    const currentMedia = media.get(index);

    const [wrapperStyles, api] = useSpring(() => ({
      x: `-${index * 100}%`,
    }));

    const handleChangeIndex = useCallback(
      (newIndex: number, animate = false) => {
        if (newIndex < 0) {
          newIndex = media.size + newIndex;
        } else if (newIndex >= media.size) {
          newIndex = newIndex % media.size;
        }
        setIndex(newIndex);
        setZoomedIn(false);
        if (animate) {
          void api.start({ x: `calc(-${newIndex * 100}% + 0px)` });
        }
      },
      [api, media.size],
    );
    const handlePrevClick = useCallback(() => {
      handleChangeIndex(index - 1, true);
    }, [handleChangeIndex, index]);
    const handleNextClick = useCallback(() => {
      handleChangeIndex(index + 1, true);
    }, [handleChangeIndex, index]);

    const handleKeyDown = useCallback(
      (event: KeyboardEvent) => {
        if (event.key === 'ArrowLeft') {
          handlePrevClick();
          event.preventDefault();
          event.stopPropagation();
        } else if (event.key === 'ArrowRight') {
          handleNextClick();
          event.preventDefault();
          event.stopPropagation();
        }
      },
      [handleNextClick, handlePrevClick],
    );

    const bind = useDrag(
      ({ active, movement: [mx], direction: [xDir], cancel }) => {
        // Disable swipe when zoomed in.
        if (zoomedIn) {
          return;
        }

        // If dragging and swipe distance is enough, change the index.
        if (
          active &&
          Math.abs(mx) > Math.min(window.innerWidth / 4, MIN_SWIPE_DISTANCE)
        ) {
          handleChangeIndex(index - xDir);
          cancel();
        }
        // Set the x position via calc to ensure proper centering regardless of screen size.
        const x = active ? mx : 0;
        void api.start({
          x: `calc(-${index * 100}% + ${x}px)`,
        });
      },
      { pointer: { capture: false } },
    );

    useEffect(() => {
      window.addEventListener('keydown', handleKeyDown, false);

      return () => {
        window.removeEventListener('keydown', handleKeyDown);
      };
    }, [handleKeyDown]);

    useEffect(() => {
      const blurhash = currentMedia?.get('blurhash') as string | undefined;
      if (blurhash) {
        const backgroundColor = getAverageFromBlurhash(blurhash);
        if (backgroundColor) {
          onChangeBackgroundColor(backgroundColor);
        }
      }
      return () => {
        onChangeBackgroundColor(null);
      };
    }, [currentMedia, onChangeBackgroundColor]);

    const [viewportDimensions, setViewportDimensions] = useState<{
      width: number;
      height: number;
    }>({ width: 0, height: 0 });
    const handleRef: RefCallback<HTMLDivElement> = useCallback((ele) => {
      if (ele?.clientWidth && ele.clientHeight) {
        setViewportDimensions({
          width: ele.clientWidth,
          height: ele.clientHeight,
        });
      }
    }, []);

    const zoomable =
      currentMedia?.get('type') === 'image' &&
      ((currentMedia.getIn(['meta', 'original', 'width']) as number) >
        viewportDimensions.width ||
        (currentMedia.getIn(['meta', 'original', 'height']) as number) >
          viewportDimensions.height);
    const handleZoomClick = useCallback(() => {
      setZoomedIn((prev) => !prev);
    }, []);

    const [navigationHidden, setNavigationHidden] = useState(false);
    const handleToggleNavigation = useCallback(() => {
      setNavigationHidden((prev) => !prev);
    }, []);

    const content = useMemo(
      () =>
        media.map((item, idx) => {
          const url = item.get('url') as string;
          const blurhash = item.get('blurhash') as string;
          const width = item.getIn(['meta', 'original', 'width'], 0) as number;
          const height = item.getIn(
            ['meta', 'original', 'height'],
            0,
          ) as number;
          const description = item.getIn(
            ['translation', 'description'],
            item.get('description'),
          ) as string;
          if (item.get('type') === 'image') {
            return (
              <ZoomableImage
                src={url}
                blurhash={blurhash}
                width={width}
                height={height}
                alt={description}
                lang={lang}
                key={url}
                onClick={handleToggleNavigation}
                onDoubleClick={handleZoomClick}
                onClose={onClose}
                onZoomChange={setZoomedIn}
                zoomedIn={zoomedIn && idx === index}
              />
            );
          } else if (item.get('type') === 'video') {
            return (
              <Video
                preview={item.get('preview_url') as string | undefined}
                blurhash={blurhash}
                src={url}
                frameRate={
                  item.getIn(['meta', 'original', 'frame_rate']) as
                    | string
                    | undefined
                }
                aspectRatio={`${width} / ${height}`}
                startTime={currentTime ?? 0}
                startPlaying={autoPlay ?? false}
                startVolume={volume ?? 1}
                onCloseVideo={onClose}
                detailed
                alt={description}
                lang={lang}
                key={url}
              />
            );
          } else if (item.get('type') === 'gifv') {
            return (
              <GIFV
                src={url}
                key={url}
                alt={description}
                lang={lang}
                onClick={handleToggleNavigation}
              />
            );
          }

          return null;
        }),
      [
        autoPlay,
        currentTime,
        handleToggleNavigation,
        handleZoomClick,
        index,
        lang,
        media,
        onClose,
        volume,
        zoomedIn,
      ],
    );

    const intl = useIntl();

    const leftNav = media.size > 1 && (
      <button
        tabIndex={0}
        className='media-modal__nav media-modal__nav--prev'
        onClick={handlePrevClick}
        aria-label={intl.formatMessage(messages.previous)}
        type='button'
      >
        <Icon id='chevron-left' icon={ChevronLeftIcon} />
      </button>
    );
    const rightNav = media.size > 1 && (
      <button
        tabIndex={0}
        className='media-modal__nav  media-modal__nav--next'
        onClick={handleNextClick}
        aria-label={intl.formatMessage(messages.next)}
        type='button'
      >
        <Icon id='chevron-right' icon={ChevronRightIcon} />
      </button>
    );

    return (
      <div
        {...bind()}
        className='modal-root__modal media-modal'
        ref={handleRef}
      >
        <animated.div
          style={wrapperStyles}
          className='media-modal__closer'
          role='presentation'
          onClick={onClose}
        >
          {content}
        </animated.div>

        <div
          className={classNames('media-modal__navigation', {
            'media-modal__navigation--hidden': navigationHidden,
          })}
        >
          <div className='media-modal__buttons'>
            {zoomable && (
              <IconButton
                title={intl.formatMessage(
                  zoomedIn ? messages.zoomOut : messages.zoomIn,
                )}
                icon=''
                iconComponent={zoomedIn ? FitScreenIcon : ActualSizeIcon}
                onClick={handleZoomClick}
              />
            )}
            <IconButton
              title={intl.formatMessage(messages.close)}
              icon='times'
              iconComponent={CloseIcon}
              onClick={onClose}
            />
          </div>

          {leftNav}
          {rightNav}

          <div className='media-modal__overlay'>
            <MediaPagination
              itemsCount={media.size}
              index={index}
              onChangeIndex={handleChangeIndex}
            />
            {statusId && (
              <Footer statusId={statusId} withOpenButton onClose={onClose} />
            )}
          </div>
        </div>
      </div>
    );
  },
);
MediaModal.displayName = 'MediaModal';

interface MediaPaginationProps {
  itemsCount: number;
  index: number;
  onChangeIndex: (newIndex: number) => void;
}

const MediaPagination: FC<MediaPaginationProps> = ({
  itemsCount,
  index,
  onChangeIndex,
}) => {
  const handleChangeIndex = useCallback(
    (curIndex: number) => {
      return () => {
        onChangeIndex(curIndex);
      };
    },
    [onChangeIndex],
  );

  if (itemsCount <= 1) {
    return null;
  }

  return (
    <ul className='media-modal__pagination'>
      {Array.from({ length: itemsCount }).map((_, i) => (
        <button
          key={i}
          className={classNames('media-modal__page-dot', {
            active: i === index,
          })}
          onClick={handleChangeIndex(i)}
          type='button'
        >
          {i + 1}
        </button>
      ))}
    </ul>
  );
};
