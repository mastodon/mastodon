import { useCallback, useEffect, useRef } from 'react';

interface AudioContextOptions {
  audioElementRef: React.RefObject<HTMLAudioElement | null>;
}

/**
 * Create and return an audio context instance for a given audio element [0].
 * Also returns an associated audio source, a gain node, and play and pause actions
 * which should be used instead of `audioElementRef.current.play/pause()`.
 *
 * [0] https://developer.mozilla.org/en-US/docs/Web/API/AudioContext
 */

export const useAudioContext = ({ audioElementRef }: AudioContextOptions) => {
  const audioContextRef = useRef<AudioContext>(null);
  const sourceRef = useRef<MediaElementAudioSourceNode>(null);
  const gainNodeRef = useRef<GainNode>(null);
  const cleanupTimeoutRef = useRef<ReturnType<typeof setTimeout>>(undefined);

  useEffect(() => {
    clearTimeout(cleanupTimeoutRef.current);
    cleanupTimeoutRef.current = undefined;

    if (!audioElementRef.current || typeof AudioContext === 'undefined') {
      return;
    }

    const context = audioContextRef.current ?? new AudioContext();
    const source =
      sourceRef.current ??
      context.createMediaElementSource(audioElementRef.current);

    const gainNode = gainNodeRef.current ?? context.createGain();
    gainNode.connect(context.destination);
    source.connect(gainNode);

    audioContextRef.current = context;
    gainNodeRef.current = gainNode;
    sourceRef.current = source;

    return () => {
      source.disconnect(gainNode);
      gainNode.disconnect();
      if (context.state !== 'closed') {
        void context.suspend();
      }
      cleanupTimeoutRef.current = setTimeout(() => {
        if (context.state !== 'closed') {
          void context.close();
        }
        audioContextRef.current = null;
        gainNodeRef.current = null;
        sourceRef.current = null;
        cleanupTimeoutRef.current = undefined;
      }, 0);
    };
  }, [audioElementRef]);

  const playAudio = useCallback(() => {
    if (audioContextRef.current && audioElementRef.current) {
      void audioElementRef.current.play();
      void audioContextRef.current.resume();
    }
  }, [audioElementRef]);

  const pauseAudio = useCallback(() => {
    if (audioContextRef.current && audioElementRef.current) {
      audioElementRef.current.pause();
      void audioContextRef.current.suspend();
    }
  }, [audioElementRef]);

  return {
    audioContextRef,
    sourceRef,
    gainNodeRef,
    playAudio,
    pauseAudio,
  };
};
