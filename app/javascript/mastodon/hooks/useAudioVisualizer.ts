import { useState, useEffect, useRef, useCallback } from 'react';

const normalizeFrequencies = (arr: Float32Array): number[] => {
  return new Array(...arr).map((value: number) => {
    if (value === -Infinity) {
      return 0;
    }

    return Math.sqrt(1 - (Math.max(-100, Math.min(-10, value)) * -1) / 100);
  });
};

export const useAudioVisualizer = (
  ref: React.MutableRefObject<HTMLAudioElement | null>,
  numBands: number,
) => {
  const audioContextRef = useRef<AudioContext>();
  const sourceRef = useRef<MediaElementAudioSourceNode>();
  const analyzerRef = useRef<AnalyserNode>();

  const [frequencyBands, setFrequencyBands] = useState<number[]>(
    new Array(numBands).fill(0),
  );

  useEffect(() => {
    if (!audioContextRef.current) {
      audioContextRef.current = new AudioContext();
      analyzerRef.current = audioContextRef.current.createAnalyser();
      analyzerRef.current.smoothingTimeConstant = 0.6;
      analyzerRef.current.fftSize = 2048;
    }

    return () => {
      if (audioContextRef.current) {
        void audioContextRef.current.close();
      }
    };
  }, []);

  useEffect(() => {
    if (
      audioContextRef.current &&
      analyzerRef.current &&
      !sourceRef.current &&
      ref.current
    ) {
      sourceRef.current = audioContextRef.current.createMediaElementSource(
        ref.current,
      );
      sourceRef.current.connect(analyzerRef.current);
      sourceRef.current.connect(audioContextRef.current.destination);
    }

    return () => {
      if (sourceRef.current) {
        sourceRef.current.disconnect();
      }
    };
  }, [ref]);

  useEffect(() => {
    const source = sourceRef.current;
    const analyzer = analyzerRef.current;
    const context = audioContextRef.current;

    if (!source || !analyzer || !context) {
      return;
    }

    const bufferLength = analyzer.frequencyBinCount;
    const frequencyData = new Float32Array(bufferLength);

    const updateProgress = () => {
      analyzer.getFloatFrequencyData(frequencyData);

      const normalizedFrequencies = normalizeFrequencies(
        frequencyData.slice(100, 600),
      );
      const bands: number[] = [];
      const chunkSize = Math.ceil(normalizedFrequencies.length / numBands);

      for (let i = 0; i < numBands; i++) {
        const sum = normalizedFrequencies
          .slice(i * chunkSize, (i + 1) * chunkSize)
          .reduce((sum, cur) => sum + cur, 0);
        bands.push(sum / chunkSize);
      }

      setFrequencyBands(bands);
    };

    const updateInterval = setInterval(updateProgress, 15);

    return () => {
      clearInterval(updateInterval);
    };
  }, [numBands]);

  const resume = useCallback(() => {
    if (audioContextRef.current) {
      void audioContextRef.current.resume();
    }
  }, []);

  const suspend = useCallback(() => {
    if (audioContextRef.current) {
      void audioContextRef.current.suspend();
    }
  }, []);

  return [resume, suspend, frequencyBands] as const;
};
