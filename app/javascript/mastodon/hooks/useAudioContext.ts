import { useCallback, useEffect, useRef } from 'react';

interface AudioContextOptions {
  audioElementRef: React.MutableRefObject<HTMLAudioElement | null>;
}

/**
 * Create and return an audio context instance for a given audio element [0].
 * Also returns an associated audio source, a gain node, and play and pause actions
 * which should be used instead of `audioElementRef.current.play/pause()`.
 *
 * [0] https://developer.mozilla.org/en-US/docs/Web/API/AudioContext
 */

export const useAudioContext = ({ audioElementRef }: AudioContextOptions) => {
  const audioContextRef = useRef<AudioContext>();
  const sourceRef = useRef<MediaElementAudioSourceNode>();
  const gainNodeRef = useRef<GainNode>();

  useEffect(() => {
    if (!audioElementRef.current) {
      return;
    }

    const context = audioContextRef.current ?? new AudioContext();
    const source =
      sourceRef.current ??
      context.createMediaElementSource(audioElementRef.current);

    const gainNode = context.createGain();
    gainNode.connect(context.destination);
    source.connect(gainNode);

    audioContextRef.current = context;
    gainNodeRef.current = gainNode;
    sourceRef.current = source;

    return () => {
      if (context.state !== 'closed') {
        void context.close();
      }
    };
  }, [audioElementRef]);

  const playAudio = useCallback(() => {
    void audioElementRef.current?.play();
    void audioContextRef.current?.resume();
  }, [audioElementRef]);

  const pauseAudio = useCallback(() => {
    audioElementRef.current?.pause();
    void audioContextRef.current?.suspend();
  }, [audioElementRef]);

  return {
    audioContextRef,
    sourceRef,
    gainNodeRef,
    playAudio,
    pauseAudio,
  };
};
