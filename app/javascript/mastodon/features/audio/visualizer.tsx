import { useId } from 'react';
import type { FC } from 'react';

import { animated, config, useSpring } from '@react-spring/web';

interface AudioVisualizerProps {
  frequencyBands?: number[];
  poster?: string;
}

export const AudioVisualizer: FC<AudioVisualizerProps> = ({
  frequencyBands = [],
  poster,
}) => {
  const accessibilityId = useId();

  const springForBand0 = useSpring({
    to: { r: 50 + (frequencyBands[0] ?? 0) * 10 },
    config: config.wobbly,
  });
  const springForBand1 = useSpring({
    to: { r: 50 + (frequencyBands[1] ?? 0) * 10 },
    config: config.wobbly,
  });
  const springForBand2 = useSpring({
    to: { r: 50 + (frequencyBands[2] ?? 0) * 10 },
    config: config.wobbly,
  });

  return (
    <svg
      className='audio-player__visualizer'
      viewBox='0 0 124 124'
      xmlns='http://www.w3.org/2000/svg'
    >
      <animated.circle
        opacity={0.5}
        cx={57}
        cy={62.5}
        r={springForBand0.r}
        fill='var(--player-accent-color)'
      />
      <animated.circle
        opacity={0.5}
        cx={65}
        cy={57.5}
        r={springForBand1.r}
        fill='var(--player-accent-color)'
      />
      <animated.circle
        opacity={0.5}
        cx={63}
        cy={66.5}
        r={springForBand2.r}
        fill='var(--player-accent-color)'
      />

      <g clipPath={`url(#${accessibilityId}-clip)`}>
        <rect
          x={14}
          y={14}
          width={96}
          height={96}
          fill={`url(#${accessibilityId}-pattern)`}
        />
        <rect
          x={14}
          y={14}
          width={96}
          height={96}
          fill='var(--player-background-color'
          opacity={0.45}
        />
      </g>

      <defs>
        <pattern
          id={`${accessibilityId}-pattern`}
          patternContentUnits='objectBoundingBox'
          width='1'
          height='1'
        >
          <use href={`#${accessibilityId}-image`} />
        </pattern>

        <clipPath id={`${accessibilityId}-clip`}>
          <rect x={14} y={14} width={96} height={96} rx={48} fill='white' />
        </clipPath>

        <image
          id={`${accessibilityId}-image`}
          href={poster}
          width={1}
          height={1}
          preserveAspectRatio='none'
        />
      </defs>
    </svg>
  );
};
