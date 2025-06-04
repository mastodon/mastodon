import { useState, useEffect, useRef } from 'react';

const normalizeFrequencies = (arr: Float32Array): number[] => {
  return new Array(...arr).map((value: number) => {
    if (value === -Infinity) {
      return 0;
    }

    return Math.sqrt(1 - (Math.max(-100, Math.min(-10, value)) * -1) / 100);
  });
};

interface AudioVisualiserOptions {
  audioContextRef: React.MutableRefObject<AudioContext | undefined>;
  sourceRef: React.MutableRefObject<MediaElementAudioSourceNode | undefined>;
  numBands: number;
}

export const useAudioVisualizer = ({
  audioContextRef,
  sourceRef,
  numBands,
}: AudioVisualiserOptions) => {
  const analyzerRef = useRef<AnalyserNode>();

  const [frequencyBands, setFrequencyBands] = useState<number[]>(
    new Array(numBands).fill(0),
  );

  useEffect(() => {
    if (audioContextRef.current) {
      analyzerRef.current = audioContextRef.current.createAnalyser();
      analyzerRef.current.smoothingTimeConstant = 0.6;
      analyzerRef.current.fftSize = 2048;
    }
  }, [audioContextRef]);

  useEffect(() => {
    if (analyzerRef.current && sourceRef.current) {
      sourceRef.current.connect(analyzerRef.current);
    }
    const currentSource = sourceRef.current;

    return () => {
      if (currentSource && analyzerRef.current) {
        currentSource.disconnect(analyzerRef.current);
      }
    };
  }, [audioContextRef, sourceRef]);

  useEffect(() => {
    const analyzer = analyzerRef.current;
    const context = audioContextRef.current;

    if (!analyzer || !context) {
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
  }, [numBands, audioContextRef]);

  return frequencyBands;
};
