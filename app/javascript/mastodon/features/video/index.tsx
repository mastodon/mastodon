import { useEffect, useCallback, useRef, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { useSpring, animated, config } from '@react-spring/web';
import { throttle } from 'lodash';

import Forward5Icon from '@/material-icons/400-24px/forward_5-fill.svg?react';
import FullscreenIcon from '@/material-icons/400-24px/fullscreen.svg?react';
import FullscreenExitIcon from '@/material-icons/400-24px/fullscreen_exit.svg?react';
import PauseIcon from '@/material-icons/400-24px/pause-fill.svg?react';
import PlayArrowIcon from '@/material-icons/400-24px/play_arrow-fill.svg?react';
import RectangleIcon from '@/material-icons/400-24px/rectangle.svg?react';
import Replay5Icon from '@/material-icons/400-24px/replay_5-fill.svg?react';
import VolumeDownIcon from '@/material-icons/400-24px/volume_down-fill.svg?react';
import VolumeOffIcon from '@/material-icons/400-24px/volume_off-fill.svg?react';
import VolumeUpIcon from '@/material-icons/400-24px/volume_up-fill.svg?react';
import { Blurhash } from 'mastodon/components/blurhash';
import { Icon } from 'mastodon/components/icon';
import { SpoilerButton } from 'mastodon/components/spoiler_button';
import {
  isFullscreen,
  requestFullscreen,
  exitFullscreen,
  attachFullscreenListener,
  detachFullscreenListener,
} from 'mastodon/features/ui/util/fullscreen';
import { displayMedia, useBlurhash } from 'mastodon/initial_state';
import { playerSettings } from 'mastodon/settings';

import { HotkeyIndicator } from './components/hotkey_indicator';
import type { HotkeyEvent } from './components/hotkey_indicator';

const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute' },
  hide: { id: 'video.hide', defaultMessage: 'Hide video' },
  expand: { id: 'video.expand', defaultMessage: 'Expand video' },
  close: { id: 'video.close', defaultMessage: 'Close video' },
  fullscreen: { id: 'video.fullscreen', defaultMessage: 'Full screen' },
  exit_fullscreen: {
    id: 'video.exit_fullscreen',
    defaultMessage: 'Exit full screen',
  },
  volumeUp: { id: 'video.volume_up', defaultMessage: 'Volume up' },
  volumeDown: { id: 'video.volume_down', defaultMessage: 'Volume down' },
  skipForward: { id: 'video.skip_forward', defaultMessage: 'Skip forward' },
  skipBackward: { id: 'video.skip_backward', defaultMessage: 'Skip backward' },
});

const DOUBLE_CLICK_THRESHOLD = 250;
const HOVER_FADE_DELAY = 4000;

export const formatTime = (secondsNum: number) => {
  const hours = Math.floor(secondsNum / 3600);
  const minutes = Math.floor((secondsNum - hours * 3600) / 60);
  const seconds = secondsNum - hours * 3600 - minutes * 60;

  const formattedHours = `${hours < 10 ? '0' : ''}${hours}`;
  const formattedMinutes = `${minutes < 10 ? '0' : ''}${minutes}`;
  const formattedSeconds = `${seconds < 10 ? '0' : ''}${seconds}`;

  return (
    (formattedHours === '00' ? '' : `${formattedHours}:`) +
    `${formattedMinutes}:${formattedSeconds}`
  );
};

export const findElementPosition = (el: HTMLElement) => {
  const box = el.getBoundingClientRect();
  const docEl = document.documentElement;
  const body = document.body;

  const clientLeft = docEl.clientLeft || body.clientLeft || 0;
  const scrollLeft = window.scrollX || body.scrollLeft;
  const left = box.left + scrollLeft - clientLeft;

  const clientTop = docEl.clientTop || body.clientTop || 0;
  const scrollTop = window.scrollY || body.scrollTop;
  const top = box.top + scrollTop - clientTop;

  return {
    left: Math.round(left),
    top: Math.round(top),
  };
};

export const getPointerPosition = (
  el: HTMLElement | null,
  event: MouseEvent,
) => {
  if (!el) {
    return {
      y: 0,
      x: 0,
    };
  }

  const box = findElementPosition(el);
  const boxW = el.offsetWidth;
  const boxH = el.offsetHeight;
  const boxY = box.top;
  const boxX = box.left;

  const { pageY, pageX } = event;

  return {
    y: Math.max(0, Math.min(1, (pageY - boxY) / boxH)),
    x: Math.max(0, Math.min(1, (pageX - boxX) / boxW)),
  };
};

export const fileNameFromURL = (str: string) => {
  const url = new URL(str);
  const pathname = url.pathname;
  const index = pathname.lastIndexOf('/');

  return pathname.slice(index + 1);
};

const frameRateAsNumber = (frameRate: string): number => {
  if (frameRate.includes('/')) {
    return frameRate
      .split('/')
      .map((c) => parseInt(c))
      .reduce((p, c) => p / c);
  }

  return parseInt(frameRate);
};

const persistVolume = (volume: number, muted: boolean) => {
  playerSettings.set('volume', volume);
  playerSettings.set('muted', muted);
};

const restoreVolume = (video: HTMLVideoElement) => {
  const volume = playerSettings.get('volume') ?? 0.5;
  const muted = playerSettings.get('muted') ?? false;

  video.volume = volume;
  video.muted = muted;
};

let hotkeyEventId = 0;

const registerHotkeyEvent = (
  setHotkeyEvents: React.Dispatch<React.SetStateAction<HotkeyEvent[]>>,
  event: Omit<HotkeyEvent, 'key'>,
) => {
  setHotkeyEvents(() => [{ key: hotkeyEventId++, ...event }]);
};

export const Video: React.FC<{
  preview?: string;
  frameRate?: string;
  aspectRatio?: string;
  src: string;
  alt?: string;
  lang?: string;
  sensitive?: boolean;
  onOpenVideo?: (options: {
    startTime: number;
    autoPlay: boolean;
    defaultVolume: number;
  }) => void;
  onCloseVideo?: () => void;
  detailed?: boolean;
  editable?: boolean;
  alwaysVisible?: boolean;
  visible?: boolean;
  onToggleVisibility?: () => void;
  deployPictureInPicture?: (
    type: string,
    mediaProps: {
      src: string;
      muted: boolean;
      volume: number;
      currentTime: number;
    },
  ) => void;
  blurhash?: string;
  startPlaying?: boolean;
  startTime?: number;
  startVolume?: number;
  startMuted?: boolean;
  matchedFilters?: string[];
}> = ({
  preview,
  frameRate = '25',
  aspectRatio,
  src,
  alt = '',
  lang,
  sensitive,
  onOpenVideo,
  onCloseVideo,
  detailed,
  editable,
  alwaysVisible,
  visible,
  onToggleVisibility,
  deployPictureInPicture,
  blurhash,
  startPlaying,
  startTime,
  startVolume,
  startMuted,
  matchedFilters,
}) => {
  const intl = useIntl();
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(0.5);
  const [paused, setPaused] = useState(true);
  const [dragging, setDragging] = useState(false);
  const [fullscreen, setFullscreen] = useState(false);
  const [hovered, setHovered] = useState(false);
  const [muted, setMuted] = useState(false);
  const [revealed, setRevealed] = useState(false);
  const [hotkeyEvents, setHotkeyEvents] = useState<HotkeyEvent[]>([]);

  const playerRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const seekRef = useRef<HTMLDivElement>(null);
  const volumeRef = useRef<HTMLDivElement>(null);
  const doubleClickTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>();
  const hoverTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>();

  const [style, api] = useSpring(() => ({
    progress: '0%',
    buffer: '0%',
    volume: '0%',
  }));

  const handleVideoRef = useCallback(
    (c: HTMLVideoElement | null) => {
      if (videoRef.current && !videoRef.current.paused && c === null) {
        deployPictureInPicture?.('video', {
          src: src,
          currentTime: videoRef.current.currentTime,
          muted: videoRef.current.muted,
          volume: videoRef.current.volume,
        });
      }

      videoRef.current = c;

      if (videoRef.current) {
        restoreVolume(videoRef.current);
        setVolume(videoRef.current.volume);
        setMuted(videoRef.current.muted);
        void api.start({
          volume: `${videoRef.current.volume * 100}%`,
        });
      }
    },
    [api, setVolume, setMuted, src, deployPictureInPicture],
  );

  const togglePlay = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    if (videoRef.current.paused) {
      void videoRef.current.play();
    } else {
      videoRef.current.pause();
    }
  }, []);

  const toggleFullscreen = useCallback(() => {
    if (isFullscreen()) {
      exitFullscreen();
    } else {
      requestFullscreen(playerRef.current);
    }
  }, []);

  const toggleMute = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    const effectivelyMuted =
      videoRef.current.muted || videoRef.current.volume === 0;

    if (effectivelyMuted) {
      videoRef.current.muted = false;

      if (videoRef.current.volume === 0) {
        videoRef.current.volume = 0.05;
      }
    } else {
      videoRef.current.muted = true;
    }
  }, []);

  const handleClickRoot = useCallback((e: React.MouseEvent) => {
    // Stop clicks within the video player e.g. closing parent modal
    e.stopPropagation();
  }, []);

  const handleClick = useCallback(() => {
    if (!doubleClickTimeoutRef.current) {
      doubleClickTimeoutRef.current = setTimeout(() => {
        registerHotkeyEvent(setHotkeyEvents, {
          icon: videoRef.current?.paused ? PlayArrowIcon : PauseIcon,
          label: videoRef.current?.paused ? messages.play : messages.pause,
        });
        togglePlay();
        doubleClickTimeoutRef.current = null;
      }, DOUBLE_CLICK_THRESHOLD);
    } else {
      clearTimeout(doubleClickTimeoutRef.current);
      doubleClickTimeoutRef.current = null;
      registerHotkeyEvent(setHotkeyEvents, {
        icon: isFullscreen() ? FullscreenExitIcon : FullscreenIcon,
        label: isFullscreen() ? messages.exit_fullscreen : messages.fullscreen,
      });
      toggleFullscreen();
    }
  }, [setHotkeyEvents, togglePlay, toggleFullscreen]);

  const handlePlay = useCallback(() => {
    setPaused(false);
  }, [setPaused]);

  const handlePause = useCallback(() => {
    setPaused(true);
  }, [setPaused]);

  useEffect(() => {
    let nextFrame: ReturnType<typeof requestAnimationFrame>;

    const updateProgress = () => {
      nextFrame = requestAnimationFrame(() => {
        if (videoRef.current) {
          const progress =
            videoRef.current.currentTime / videoRef.current.duration;
          void api.start({
            progress: isNaN(progress) ? '0%' : `${progress * 100}%`,
            config: config.stiff,
          });
        }

        updateProgress();
      });
    };

    updateProgress();

    return () => {
      cancelAnimationFrame(nextFrame);
    };
  }, [api]);

  useEffect(() => {
    if (!videoRef.current) {
      return;
    }

    videoRef.current.volume = volume;
    videoRef.current.muted = muted;
  }, [volume, muted]);

  useEffect(() => {
    if (typeof visible !== 'undefined') {
      setRevealed(visible);
    } else {
      setRevealed(
        displayMedia === 'show_all' ||
          (displayMedia !== 'hide_all' && !sensitive),
      );
    }
  }, [visible, sensitive]);

  useEffect(() => {
    if (!revealed && videoRef.current) {
      videoRef.current.pause();
    }
  }, [revealed]);

  useEffect(() => {
    const handleFullscreenChange = () => {
      setFullscreen(isFullscreen());
    };

    const handleScroll = throttle(
      () => {
        if (!videoRef.current) {
          return;
        }

        const { top, height } = videoRef.current.getBoundingClientRect();
        const inView =
          top <=
            (window.innerHeight || document.documentElement.clientHeight) &&
          top + height >= 0;

        if (!videoRef.current.paused && !inView) {
          videoRef.current.pause();

          deployPictureInPicture?.('video', {
            src: src,
            currentTime: videoRef.current.currentTime,
            muted: videoRef.current.muted,
            volume: videoRef.current.volume,
          });
        }
      },
      150,
      { trailing: true },
    );

    attachFullscreenListener(handleFullscreenChange);
    window.addEventListener('scroll', handleScroll);

    return () => {
      window.removeEventListener('scroll', handleScroll);
      detachFullscreenListener(handleFullscreenChange);
    };
  }, [setPaused, setFullscreen, src, deployPictureInPicture]);

  const handleTimeUpdate = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    setCurrentTime(videoRef.current.currentTime);
  }, [setCurrentTime]);

  const handleVolumeMouseDown = useCallback(
    (e: React.MouseEvent) => {
      const handleVolumeMouseUp = () => {
        document.removeEventListener('mousemove', handleVolumeMouseMove, true);
        document.removeEventListener('mouseup', handleVolumeMouseUp, true);
      };

      const handleVolumeMouseMove = (e: MouseEvent) => {
        if (!volumeRef.current || !videoRef.current) {
          return;
        }

        const { x } = getPointerPosition(volumeRef.current, e);

        if (!isNaN(x)) {
          videoRef.current.volume = x;
          videoRef.current.muted = x > 0 ? false : true;
          void api.start({ volume: `${x * 100}%`, immediate: true });
        }
      };

      document.addEventListener('mousemove', handleVolumeMouseMove, true);
      document.addEventListener('mouseup', handleVolumeMouseUp, true);

      handleVolumeMouseMove(e.nativeEvent);

      e.preventDefault();
      e.stopPropagation();
    },
    [api],
  );

  const handleSeekMouseDown = useCallback(
    (e: React.MouseEvent) => {
      const handleSeekMouseUp = () => {
        document.removeEventListener('mousemove', handleSeekMouseMove, true);
        document.removeEventListener('mouseup', handleSeekMouseUp, true);

        setDragging(false);
        void videoRef.current?.play();
      };

      const handleSeekMouseMove = (e: MouseEvent) => {
        if (!seekRef.current || !videoRef.current) {
          return;
        }

        const { x } = getPointerPosition(seekRef.current, e);
        const newTime = videoRef.current.duration * x;

        if (!isNaN(newTime)) {
          videoRef.current.currentTime = newTime;
          void api.start({ progress: `${x * 100}%`, immediate: true });
        }
      };

      document.addEventListener('mousemove', handleSeekMouseMove, true);
      document.addEventListener('mouseup', handleSeekMouseUp, true);

      setDragging(true);
      videoRef.current?.pause();
      handleSeekMouseMove(e.nativeEvent);

      e.preventDefault();
      e.stopPropagation();
    },
    [setDragging, api],
  );

  const seekBy = (time: number) => {
    if (!videoRef.current) {
      return;
    }

    const newTime = videoRef.current.currentTime + time;

    if (!isNaN(newTime)) {
      videoRef.current.currentTime = newTime;
    }
  };

  const updateVolumeBy = (step: number) => {
    if (!videoRef.current) {
      return;
    }

    const newVolume = videoRef.current.volume + step;

    if (!isNaN(newVolume)) {
      videoRef.current.volume = newVolume;
      videoRef.current.muted = newVolume > 0 ? false : true;
    }
  };

  const handleVideoKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      // On the video element or the seek bar, we can safely use the space bar
      // for playback control because there are no buttons to press

      if (e.key === ' ') {
        e.preventDefault();
        e.stopPropagation();
        registerHotkeyEvent(setHotkeyEvents, {
          icon: videoRef.current?.paused ? PlayArrowIcon : PauseIcon,
          label: videoRef.current?.paused ? messages.play : messages.pause,
        });
        togglePlay();
      }
    },
    [setHotkeyEvents, togglePlay],
  );

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      const frameTime = 1 / frameRateAsNumber(frameRate);

      switch (e.key) {
        case 'k':
        case ' ':
          e.preventDefault();
          e.stopPropagation();
          registerHotkeyEvent(setHotkeyEvents, {
            icon: videoRef.current?.paused ? PlayArrowIcon : PauseIcon,
            label: videoRef.current?.paused ? messages.play : messages.pause,
          });
          togglePlay();
          break;
        case 'm':
          e.preventDefault();
          e.stopPropagation();
          registerHotkeyEvent(setHotkeyEvents, {
            icon: videoRef.current?.muted ? VolumeUpIcon : VolumeOffIcon,
            label: videoRef.current?.muted ? messages.unmute : messages.mute,
          });
          toggleMute();
          break;
        case 'f':
          e.preventDefault();
          e.stopPropagation();
          registerHotkeyEvent(setHotkeyEvents, {
            icon: isFullscreen() ? FullscreenExitIcon : FullscreenIcon,
            label: isFullscreen()
              ? messages.exit_fullscreen
              : messages.fullscreen,
          });
          toggleFullscreen();
          break;
        case 'j':
        case 'ArrowLeft':
          e.preventDefault();
          e.stopPropagation();
          registerHotkeyEvent(setHotkeyEvents, {
            icon: Replay5Icon,
            label: messages.skipBackward,
          });
          seekBy(-5);
          break;
        case 'l':
        case 'ArrowRight':
          e.preventDefault();
          e.stopPropagation();
          registerHotkeyEvent(setHotkeyEvents, {
            icon: Forward5Icon,
            label: messages.skipForward,
          });
          seekBy(5);
          break;
        case ',':
          e.preventDefault();
          e.stopPropagation();
          seekBy(-frameTime);
          break;
        case '.':
          e.preventDefault();
          e.stopPropagation();
          seekBy(frameTime);
          break;
        case 'ArrowUp':
          e.preventDefault();
          e.stopPropagation();
          registerHotkeyEvent(setHotkeyEvents, {
            icon: VolumeUpIcon,
            label: messages.volumeUp,
          });
          updateVolumeBy(0.15);
          break;
        case 'ArrowDown':
          e.preventDefault();
          e.stopPropagation();
          registerHotkeyEvent(setHotkeyEvents, {
            icon: VolumeDownIcon,
            label: messages.volumeDown,
          });
          updateVolumeBy(-0.15);
          break;
      }

      // If we are in fullscreen mode, we don't want any hotkeys
      // interacting with the UI that's not visible

      if (fullscreen) {
        e.preventDefault();
        e.stopPropagation();

        if (e.key === 'Escape') {
          setHotkeyEvents((events) => [
            ...events,
            {
              key: hotkeyEventId++,
              icon: FullscreenExitIcon,
              label: messages.exit_fullscreen,
            },
          ]);
          exitFullscreen();
        }
      }
    },
    [
      setHotkeyEvents,
      togglePlay,
      toggleFullscreen,
      toggleMute,
      fullscreen,
      frameRate,
    ],
  );

  const handleMouseEnter = useCallback(() => {
    setHovered(true);

    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
    }

    hoverTimeoutRef.current = setTimeout(() => {
      setHovered(false);
    }, HOVER_FADE_DELAY);
  }, [setHovered]);

  const handleMouseMove = useCallback(() => {
    setHovered(true);

    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
    }

    hoverTimeoutRef.current = setTimeout(() => {
      setHovered(false);
    }, HOVER_FADE_DELAY);
  }, [setHovered]);

  const handleMouseLeave = useCallback(() => {
    setHovered(false);
  }, [setHovered]);

  const toggleReveal = useCallback(() => {
    if (onToggleVisibility) {
      onToggleVisibility();
    } else {
      setRevealed((value) => !value);
    }
  }, [setRevealed, onToggleVisibility]);

  const handleLoadedData = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    setDuration(videoRef.current.duration);

    if (typeof startTime !== 'undefined') {
      videoRef.current.currentTime = startTime;
    }

    if (typeof startVolume !== 'undefined') {
      videoRef.current.volume = startVolume;
    }

    if (typeof startMuted !== 'undefined') {
      videoRef.current.muted = startMuted;
    }

    if (startPlaying) {
      void videoRef.current.play();
    }
  }, [setDuration, startTime, startVolume, startMuted, startPlaying]);

  const handleProgress = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    const lastTimeRange = videoRef.current.buffered.length - 1;

    if (lastTimeRange > -1) {
      void api.start({
        buffer: `${Math.ceil(videoRef.current.buffered.end(lastTimeRange) / videoRef.current.duration) * 100}%`,
      });
    }
  }, [api]);

  const handleVolumeChange = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    setVolume(videoRef.current.volume);
    setMuted(videoRef.current.muted);

    void api.start({
      volume: `${videoRef.current.muted ? 0 : videoRef.current.volume * 100}%`,
    });

    persistVolume(videoRef.current.volume, videoRef.current.muted);
  }, [api, setVolume, setMuted]);

  const handleOpenVideo = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    const wasPaused = videoRef.current.paused;

    videoRef.current.pause();

    onOpenVideo?.({
      startTime: videoRef.current.currentTime,
      autoPlay: !wasPaused,
      defaultVolume: videoRef.current.volume,
    });
  }, [onOpenVideo]);

  const handleCloseVideo = useCallback(() => {
    if (!videoRef.current) {
      return;
    }

    videoRef.current.pause();

    onCloseVideo?.();
  }, [onCloseVideo]);

  const handleHotkeyEventDismiss = useCallback(
    ({ key }: HotkeyEvent) => {
      setHotkeyEvents((events) => events.filter((e) => e.key !== key));
    },
    [setHotkeyEvents],
  );

  const progress = Math.min((currentTime / duration) * 100, 100);
  const effectivelyMuted = muted || volume === 0;

  let preload;

  if (startTime || fullscreen || dragging) {
    preload = 'auto';
  } else if (detailed) {
    preload = 'metadata';
  } else {
    preload = 'none';
  }

  // The outer wrapper is necessary to avoid reflowing the layout when going into full screen
  return (
    <div>
      <div /* eslint-disable-line jsx-a11y/click-events-have-key-events */
        role='menuitem'
        className={classNames('video-player', {
          inactive: !revealed,
          detailed,
          fullscreen,
          editable,
        })}
        style={{ aspectRatio }}
        ref={playerRef}
        onMouseEnter={handleMouseEnter}
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
        onClick={handleClickRoot}
        onKeyDownCapture={handleKeyDown}
        tabIndex={0}
      >
        {blurhash && (
          <Blurhash
            hash={blurhash}
            className={classNames('media-gallery__preview', {
              'media-gallery__preview--hidden': revealed,
            })}
            dummy={!useBlurhash}
          />
        )}

        {(revealed || editable) && (
          <video /* eslint-disable-line jsx-a11y/media-has-caption */
            ref={handleVideoRef}
            src={src}
            poster={preview}
            preload={preload}
            role='button'
            tabIndex={0}
            aria-label={alt}
            title={alt}
            lang={lang}
            onClick={handleClick}
            onKeyDownCapture={handleVideoKeyDown}
            onPlay={handlePlay}
            onPause={handlePause}
            onLoadedData={handleLoadedData}
            onProgress={handleProgress}
            onTimeUpdate={handleTimeUpdate}
            onVolumeChange={handleVolumeChange}
            style={{ width: '100%' }}
          />
        )}

        <HotkeyIndicator
          events={hotkeyEvents}
          onDismiss={handleHotkeyEventDismiss}
        />

        <SpoilerButton
          hidden={revealed || editable}
          sensitive={sensitive ?? false}
          onClick={toggleReveal}
          matchedFilters={matchedFilters}
        />

        {!onCloseVideo &&
          !editable &&
          !fullscreen &&
          !alwaysVisible &&
          revealed && (
            <div
              className={classNames('media-gallery__actions', {
                active: paused || hovered,
              })}
            >
              <button
                className='media-gallery__actions__pill'
                onClick={toggleReveal}
                type='button'
              >
                <FormattedMessage
                  id='media_gallery.hide'
                  defaultMessage='Hide'
                />
              </button>
            </div>
          )}

        <div
          className={classNames('video-player__controls', {
            active: paused || hovered,
          })}
        >
          <div
            className='video-player__seek'
            role='slider'
            aria-valuemin={0}
            aria-valuenow={progress}
            aria-valuemax={100}
            onMouseDown={handleSeekMouseDown}
            onKeyDown={handleVideoKeyDown}
            tabIndex={0}
            ref={seekRef}
          >
            <animated.div
              className='video-player__seek__buffer'
              style={{ width: style.buffer }}
            />
            <animated.div
              className='video-player__seek__progress'
              style={{ width: style.progress }}
            />

            <animated.span
              className={classNames('video-player__seek__handle', {
                active: dragging,
              })}
              style={{ left: style.progress }}
            />
          </div>

          <div className='video-player__buttons-bar'>
            <div className='video-player__buttons left'>
              <button
                type='button'
                title={intl.formatMessage(
                  paused ? messages.play : messages.pause,
                )}
                aria-label={intl.formatMessage(
                  paused ? messages.play : messages.pause,
                )}
                className='player-button'
                onClick={togglePlay}
              >
                <Icon
                  id={paused ? 'play' : 'pause'}
                  icon={paused ? PlayArrowIcon : PauseIcon}
                />
              </button>
              <button
                type='button'
                title={intl.formatMessage(
                  effectivelyMuted ? messages.unmute : messages.mute,
                )}
                aria-label={intl.formatMessage(
                  muted ? messages.unmute : messages.mute,
                )}
                className='player-button'
                onClick={toggleMute}
              >
                <Icon
                  id={effectivelyMuted ? 'volume-off' : 'volume-up'}
                  icon={effectivelyMuted ? VolumeOffIcon : VolumeUpIcon}
                />
              </button>

              <div
                className={classNames('video-player__volume', {
                  active: hovered,
                })}
                role='slider'
                aria-valuemin={0}
                aria-valuenow={effectivelyMuted ? 0 : volume * 100}
                aria-valuemax={100}
                onMouseDown={handleVolumeMouseDown}
                ref={volumeRef}
                tabIndex={0}
              >
                <animated.div
                  className='video-player__volume__current'
                  style={{ width: style.volume }}
                />

                <animated.span
                  className={classNames('video-player__volume__handle')}
                  style={{ left: style.volume }}
                />
              </div>

              {(detailed || fullscreen) && (
                <span className='video-player__time'>
                  <span className='video-player__time-current'>
                    {formatTime(Math.floor(currentTime))}
                  </span>
                  <span className='video-player__time-sep'>/</span>
                  <span className='video-player__time-total'>
                    {formatTime(Math.floor(duration))}
                  </span>
                </span>
              )}
            </div>

            <div className='video-player__buttons right'>
              {!fullscreen && onOpenVideo && (
                <button
                  type='button'
                  title={intl.formatMessage(messages.expand)}
                  aria-label={intl.formatMessage(messages.expand)}
                  className='player-button'
                  onClick={handleOpenVideo}
                >
                  <Icon id='expand' icon={RectangleIcon} />
                </button>
              )}
              {onCloseVideo && (
                <button
                  type='button'
                  title={intl.formatMessage(messages.close)}
                  aria-label={intl.formatMessage(messages.close)}
                  className='player-button'
                  onClick={handleCloseVideo}
                >
                  <Icon id='compress' icon={FullscreenExitIcon} />
                </button>
              )}
              <button
                type='button'
                title={intl.formatMessage(
                  fullscreen ? messages.exit_fullscreen : messages.fullscreen,
                )}
                aria-label={intl.formatMessage(
                  fullscreen ? messages.exit_fullscreen : messages.fullscreen,
                )}
                className='player-button'
                onClick={toggleFullscreen}
              >
                <Icon
                  id={fullscreen ? 'compress' : 'arrows-alt'}
                  icon={fullscreen ? FullscreenExitIcon : FullscreenIcon}
                />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default Video;
