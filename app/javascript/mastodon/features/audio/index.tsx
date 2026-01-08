import { useEffect, useRef, useCallback, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { useSpring, animated, config } from '@react-spring/web';

import DownloadIcon from '@/material-icons/400-24px/download.svg?react';
import Forward5Icon from '@/material-icons/400-24px/forward_5-fill.svg?react';
import PauseIcon from '@/material-icons/400-24px/pause-fill.svg?react';
import PlayArrowIcon from '@/material-icons/400-24px/play_arrow-fill.svg?react';
import Replay5Icon from '@/material-icons/400-24px/replay_5-fill.svg?react';
import VolumeOffIcon from '@/material-icons/400-24px/volume_off-fill.svg?react';
import VolumeUpIcon from '@/material-icons/400-24px/volume_up-fill.svg?react';
import { Blurhash } from 'mastodon/components/blurhash';
import { Icon } from 'mastodon/components/icon';
import { SpoilerButton } from 'mastodon/components/spoiler_button';
import { formatTime, getPointerPosition } from 'mastodon/features/video';
import { useAudioContext } from 'mastodon/hooks/useAudioContext';
import { useAudioVisualizer } from 'mastodon/hooks/useAudioVisualizer';
import { displayMedia, useBlurhash } from 'mastodon/initial_state';
import { playerSettings } from 'mastodon/settings';

import { AudioVisualizer } from './visualizer';

const messages = defineMessages({
  play: { id: 'video.play', defaultMessage: 'Play' },
  pause: { id: 'video.pause', defaultMessage: 'Pause' },
  mute: { id: 'video.mute', defaultMessage: 'Mute' },
  unmute: { id: 'video.unmute', defaultMessage: 'Unmute' },
  download: { id: 'video.download', defaultMessage: 'Download file' },
  hide: { id: 'audio.hide', defaultMessage: 'Hide audio' },
  skipForward: { id: 'video.skip_forward', defaultMessage: 'Skip forward' },
  skipBackward: { id: 'video.skip_backward', defaultMessage: 'Skip backward' },
});

const persistVolume = (volume: number, muted: boolean) => {
  playerSettings.set('volume', volume);
  playerSettings.set('muted', muted);
};

const restoreVolume = (audio: HTMLAudioElement) => {
  const volume = playerSettings.get('volume') ?? 0.5;
  const muted = playerSettings.get('muted') ?? false;

  audio.volume = volume;
  audio.muted = muted;
};

const HOVER_FADE_DELAY = 4000;

export const Audio: React.FC<{
  src: string;
  alt?: string;
  lang?: string;
  poster?: string;
  sensitive?: boolean;
  editable?: boolean;
  blurhash?: string;
  visible?: boolean;
  duration?: number;
  onToggleVisibility?: () => void;
  backgroundColor?: string;
  foregroundColor?: string;
  accentColor?: string;
  startTime?: number;
  startPlaying?: boolean;
  startVolume?: number;
  startMuted?: boolean;
  deployPictureInPicture?: (
    type: string,
    mediaProps: {
      src: string;
      muted: boolean;
      volume: number;
      currentTime: number;
      poster?: string;
      backgroundColor: string;
      foregroundColor: string;
      accentColor: string;
    },
  ) => void;
  matchedFilters?: string[];
}> = ({
  src,
  alt,
  lang,
  poster,
  duration,
  sensitive,
  editable,
  blurhash,
  visible,
  onToggleVisibility,
  backgroundColor = '#000000',
  foregroundColor = '#ffffff',
  accentColor = '#ffffff',
  startTime,
  startPlaying,
  startVolume,
  startMuted,
  deployPictureInPicture,
  matchedFilters,
}) => {
  const intl = useIntl();
  const [currentTime, setCurrentTime] = useState(0);
  const [loadedDuration, setDuration] = useState(duration ?? 0);
  const [paused, setPaused] = useState(true);
  const [muted, setMuted] = useState(false);
  const [volume, setVolume] = useState(0.5);
  const [hovered, setHovered] = useState(false);
  const [dragging, setDragging] = useState(false);
  const [revealed, setRevealed] = useState(false);

  const playerRef = useRef<HTMLDivElement>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const seekRef = useRef<HTMLDivElement>(null);
  const volumeRef = useRef<HTMLDivElement>(null);
  const hoverTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>();

  const { audioContextRef, sourceRef, gainNodeRef, playAudio, pauseAudio } =
    useAudioContext({ audioElementRef: audioRef });

  const frequencyBands = useAudioVisualizer({
    audioContextRef,
    sourceRef,
    numBands: 3,
  });

  const [style, spring] = useSpring(() => ({
    progress: '0%',
    buffer: '0%',
    volume: '0%',
  }));

  const handleAudioRef = useCallback(
    (c: HTMLVideoElement | null) => {
      if (audioRef.current && !audioRef.current.paused && c === null) {
        deployPictureInPicture?.('audio', {
          src,
          poster,
          backgroundColor,
          foregroundColor,
          accentColor,
          currentTime: audioRef.current.currentTime,
          muted: audioRef.current.muted,
          volume: audioRef.current.volume,
        });
      }

      audioRef.current = c;

      if (audioRef.current) {
        restoreVolume(audioRef.current);
        setVolume(audioRef.current.volume);
        setMuted(audioRef.current.muted);
        if (gainNodeRef.current) {
          gainNodeRef.current.gain.value = audioRef.current.volume;
        }
        void spring.start({
          volume: `${audioRef.current.volume * 100}%`,
        });
      }
    },
    [
      deployPictureInPicture,
      src,
      poster,
      backgroundColor,
      foregroundColor,
      accentColor,
      gainNodeRef,
      spring,
    ],
  );

  useEffect(() => {
    if (!audioRef.current) {
      return;
    }

    audioRef.current.volume = volume;
    audioRef.current.muted = muted;

    if (gainNodeRef.current) {
      gainNodeRef.current.gain.value = muted ? 0 : volume;
    }
  }, [volume, muted, gainNodeRef]);

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
    if (!revealed) {
      pauseAudio();
    }
  }, [pauseAudio, revealed]);

  useEffect(() => {
    let nextFrame: ReturnType<typeof requestAnimationFrame>;

    const updateProgress = () => {
      nextFrame = requestAnimationFrame(() => {
        if (audioRef.current && audioRef.current.duration > 0) {
          void spring.start({
            progress: `${(audioRef.current.currentTime / audioRef.current.duration) * 100}%`,
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
  }, [spring]);

  const togglePlay = useCallback(() => {
    if (!audioRef.current) {
      return;
    }

    if (audioRef.current.paused) {
      playAudio();
    } else {
      pauseAudio();
    }
  }, [playAudio, pauseAudio]);

  const handlePlay = useCallback(() => {
    setPaused(false);
  }, []);

  const handlePause = useCallback(() => {
    setPaused(true);
  }, []);

  const handleProgress = useCallback(() => {
    if (!audioRef.current) {
      return;
    }

    const lastTimeRange = audioRef.current.buffered.length - 1;

    if (lastTimeRange > -1) {
      void spring.start({
        buffer: `${Math.ceil(audioRef.current.buffered.end(lastTimeRange) / audioRef.current.duration) * 100}%`,
      });
    }
  }, [spring]);

  const handleVolumeChange = useCallback(() => {
    if (!audioRef.current) {
      return;
    }

    setVolume(audioRef.current.volume);
    setMuted(audioRef.current.muted);

    void spring.start({
      volume: `${audioRef.current.muted ? 0 : audioRef.current.volume * 100}%`,
    });

    persistVolume(audioRef.current.volume, audioRef.current.muted);
  }, [spring, setVolume, setMuted]);

  const handleTimeUpdate = useCallback(() => {
    if (!audioRef.current) {
      return;
    }

    setCurrentTime(audioRef.current.currentTime);
  }, [setCurrentTime]);

  const toggleMute = useCallback(() => {
    if (!audioRef.current) {
      return;
    }

    const effectivelyMuted =
      audioRef.current.muted || audioRef.current.volume === 0;

    if (effectivelyMuted) {
      audioRef.current.muted = false;

      if (audioRef.current.volume === 0) {
        audioRef.current.volume = 0.05;
      }
    } else {
      audioRef.current.muted = true;
    }
  }, []);

  const toggleReveal = useCallback(() => {
    if (onToggleVisibility) {
      onToggleVisibility();
    } else {
      setRevealed((value) => !value);
    }
  }, [onToggleVisibility, setRevealed]);

  const handleVolumeMouseDown = useCallback(
    (e: React.MouseEvent) => {
      const handleVolumeMouseUp = () => {
        document.removeEventListener('mousemove', handleVolumeMouseMove, true);
        document.removeEventListener('mouseup', handleVolumeMouseUp, true);
      };

      const handleVolumeMouseMove = (e: MouseEvent) => {
        if (!volumeRef.current || !audioRef.current) {
          return;
        }

        const { x } = getPointerPosition(volumeRef.current, e);

        if (!isNaN(x)) {
          audioRef.current.volume = x;
          audioRef.current.muted = x > 0 ? false : true;
          void spring.start({ volume: `${x * 100}%`, immediate: true });
        }
      };

      document.addEventListener('mousemove', handleVolumeMouseMove, true);
      document.addEventListener('mouseup', handleVolumeMouseUp, true);

      handleVolumeMouseMove(e.nativeEvent);

      e.preventDefault();
      e.stopPropagation();
    },
    [spring],
  );

  const handleSeekMouseDown = useCallback(
    (e: React.MouseEvent) => {
      const handleSeekMouseUp = () => {
        document.removeEventListener('mousemove', handleSeekMouseMove, true);
        document.removeEventListener('mouseup', handleSeekMouseUp, true);

        setDragging(false);
        playAudio();
      };

      const handleSeekMouseMove = (e: MouseEvent) => {
        if (!seekRef.current || !audioRef.current) {
          return;
        }

        const { x } = getPointerPosition(seekRef.current, e);
        const newTime = audioRef.current.duration * x;

        if (!isNaN(newTime)) {
          audioRef.current.currentTime = newTime;
          void spring.start({ progress: `${x * 100}%`, immediate: true });
        }
      };

      document.addEventListener('mousemove', handleSeekMouseMove, true);
      document.addEventListener('mouseup', handleSeekMouseUp, true);

      setDragging(true);
      audioRef.current?.pause();
      handleSeekMouseMove(e.nativeEvent);

      e.preventDefault();
      e.stopPropagation();
    },
    [playAudio, spring],
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

    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
    }
  }, [setHovered]);

  const handleTouchEnd = useCallback(() => {
    setHovered(true);

    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
    }

    hoverTimeoutRef.current = setTimeout(() => {
      setHovered(false);
    }, HOVER_FADE_DELAY);
  }, [setHovered]);

  const handleLoadedData = useCallback(() => {
    if (!audioRef.current) {
      return;
    }

    setDuration(audioRef.current.duration);

    if (typeof startTime !== 'undefined') {
      audioRef.current.currentTime = startTime;
    }

    if (typeof startVolume !== 'undefined') {
      audioRef.current.volume = startVolume;
    }

    if (typeof startMuted !== 'undefined') {
      audioRef.current.muted = startMuted;
    }
  }, [setDuration, startTime, startVolume, startMuted]);

  const handleCanPlayThrough = useCallback(() => {
    if (startPlaying) {
      playAudio();
    }
  }, [startPlaying, playAudio]);

  const seekBy = (time: number) => {
    if (!audioRef.current) {
      return;
    }

    const newTime = audioRef.current.currentTime + time;

    if (!isNaN(newTime)) {
      audioRef.current.currentTime = newTime;
    }
  };

  const handleAudioKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      // On the audio element or the seek bar, we can safely use the space bar
      // for playback control because there are no buttons to press

      if (e.key === ' ') {
        e.preventDefault();
        e.stopPropagation();
        togglePlay();
      }
    },
    [togglePlay],
  );

  const handleSkipBackward = useCallback(() => {
    seekBy(-5);
  }, []);

  const handleSkipForward = useCallback(() => {
    seekBy(5);
  }, []);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      const updateVolumeBy = (step: number) => {
        if (!audioRef.current) {
          return;
        }

        const newVolume = Math.max(0, audioRef.current.volume + step);

        if (!isNaN(newVolume)) {
          audioRef.current.volume = newVolume;
          audioRef.current.muted = newVolume > 0 ? false : true;
        }
      };

      switch (e.key) {
        case 'k':
        case ' ':
          e.preventDefault();
          e.stopPropagation();
          togglePlay();
          break;
        case 'm':
          e.preventDefault();
          e.stopPropagation();
          toggleMute();
          break;
        case 'j':
        case 'ArrowLeft':
          e.preventDefault();
          e.stopPropagation();
          seekBy(-5);
          break;
        case 'l':
        case 'ArrowRight':
          e.preventDefault();
          e.stopPropagation();
          seekBy(5);
          break;
        case 'ArrowUp':
          e.preventDefault();
          e.stopPropagation();
          updateVolumeBy(0.15);
          break;
        case 'ArrowDown':
          e.preventDefault();
          e.stopPropagation();
          updateVolumeBy(-0.15);
          break;
      }
    },
    [togglePlay, toggleMute],
  );

  const progress = Math.min((currentTime / loadedDuration) * 100, 100);
  const effectivelyMuted = muted || volume === 0;

  return (
    <div
      className={classNames('audio-player', { inactive: !revealed })}
      ref={playerRef}
      style={
        {
          '--player-background-color': backgroundColor,
          '--player-foreground-color': foregroundColor,
          '--player-accent-color': accentColor,
        } as React.CSSProperties
      }
      onMouseEnter={handleMouseEnter}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      onTouchEnd={handleTouchEnd}
      role='button'
      tabIndex={0}
      onKeyDownCapture={handleKeyDown}
      aria-label={alt}
      lang={lang}
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

      <audio /* eslint-disable-line jsx-a11y/media-has-caption */
        src={src}
        ref={handleAudioRef}
        preload={startPlaying ? 'auto' : 'none'}
        onPlay={handlePlay}
        onPause={handlePause}
        onProgress={handleProgress}
        onLoadedData={handleLoadedData}
        onCanPlayThrough={handleCanPlayThrough}
        onTimeUpdate={handleTimeUpdate}
        onVolumeChange={handleVolumeChange}
        crossOrigin='anonymous'
      />

      <div
        className='video-player__seek'
        aria-valuemin={0}
        aria-valuenow={progress}
        aria-valuemax={100}
        onMouseDown={handleSeekMouseDown}
        onKeyDownCapture={handleAudioKeyDown}
        ref={seekRef}
        role='slider'
        tabIndex={0}
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

      <div className='audio-player__controls'>
        <div className='audio-player__controls__play'>
          <button
            type='button'
            title={intl.formatMessage(messages.skipBackward)}
            aria-label={intl.formatMessage(messages.skipBackward)}
            className='player-button'
            onClick={handleSkipBackward}
          >
            <Icon id='' icon={Replay5Icon} />
          </button>
        </div>

        <div className='audio-player__controls__play'>
          <AudioVisualizer frequencyBands={frequencyBands} poster={poster} />

          <button
            type='button'
            title={intl.formatMessage(paused ? messages.play : messages.pause)}
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
        </div>

        <div className='audio-player__controls__play'>
          <button
            type='button'
            title={intl.formatMessage(messages.skipForward)}
            aria-label={intl.formatMessage(messages.skipForward)}
            className='player-button'
            onClick={handleSkipForward}
          >
            <Icon id='' icon={Forward5Icon} />
          </button>
        </div>
      </div>

      <SpoilerButton
        hidden={revealed || editable}
        sensitive={sensitive ?? false}
        onClick={toggleReveal}
        matchedFilters={matchedFilters}
      />

      <div
        className={classNames('video-player__controls', { active: hovered })}
      >
        <div className='video-player__buttons-bar'>
          <div className='video-player__buttons left'>
            <button
              type='button'
              title={intl.formatMessage(
                muted ? messages.unmute : messages.mute,
              )}
              aria-label={intl.formatMessage(
                muted ? messages.unmute : messages.mute,
              )}
              className='player-button'
              onClick={toggleMute}
            >
              <Icon
                id={muted ? 'volume-off' : 'volume-up'}
                icon={muted ? VolumeOffIcon : VolumeUpIcon}
              />
            </button>

            <div
              className='video-player__volume active'
              ref={volumeRef}
              onMouseDown={handleVolumeMouseDown}
              role='slider'
              aria-valuemin={0}
              aria-valuenow={effectivelyMuted ? 0 : volume * 100}
              aria-valuemax={100}
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

            <span className='video-player__time'>
              <span className='video-player__time-current'>
                {formatTime(Math.floor(currentTime))}
              </span>
              <span className='video-player__time-sep'>/</span>
              <span className='video-player__time-total'>
                {formatTime(Math.floor(loadedDuration))}
              </span>
            </span>
          </div>

          <div className='video-player__buttons right'>
            {!editable && (
              <>
                <button
                  type='button'
                  className='player-button'
                  onClick={toggleReveal}
                >
                  <FormattedMessage
                    id='media_gallery.hide'
                    defaultMessage='Hide'
                  />
                </button>

                <a
                  title={intl.formatMessage(messages.download)}
                  aria-label={intl.formatMessage(messages.download)}
                  className='video-player__download__icon player-button'
                  href={src}
                  download
                >
                  <Icon id='download' icon={DownloadIcon} />
                </a>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default Audio;
