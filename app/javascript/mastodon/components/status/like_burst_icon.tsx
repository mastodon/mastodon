import classNames from 'classnames';

import { HeartIcon } from '@phosphor-icons/react';

import type { IconProp } from '../icon';

import classes from './like_burst_icon.module.scss';

const CENTER_X = 128;
const CENTER_Y = 136;

const WAVE_1_COLORS = ['#ff8ac5', '#66c8f5', '#f5c542', '#71d4c2', '#cc8ef5'];
const WAVE_2_COLORS = ['#9b8af5', '#7ed9c3', '#f59ec5', '#66c8f5', '#ffb347'];

const confetti = (
  startAngle: number,
  distance: number,
  size: number,
  colors: string[],
) =>
  colors.map((color, i) => {
    const angle = startAngle + (i / colors.length) * Math.PI * 2;

    return {
      cx: Math.round(CENTER_X + Math.cos(angle) * distance),
      cy: Math.round(CENTER_Y + Math.sin(angle) * distance),
      r: size,
      fill: color,
    };
  });

const WAVE_1 = confetti(-0.3, 209, 14, WAVE_1_COLORS);
const WAVE_2 = confetti(0.08, 252, 9, WAVE_2_COLORS);

const likeBurstIcon = (weight: 'regular' | 'fill'): IconProp => {
  const LikeBurstIcon: IconProp = ({ className, ...props }) => (
    <HeartIcon
      {...props}
      className={classNames(className, classes.likeBurstIcon)}
      weight={weight}
    >
      <circle
        className={classes.ring}
        cx='128'
        cy='136'
        r='123'
        fill='none'
        stroke='currentColor'
        strokeWidth='16'
      />
      <g className={classes.confetti}>
        {WAVE_1.map((dot) => (
          <circle key={dot.fill} {...dot} />
        ))}
      </g>
      <g className={classes.confetti}>
        {WAVE_2.map((dot) => (
          <circle key={dot.fill} {...dot} />
        ))}
      </g>
    </HeartIcon>
  );
  return LikeBurstIcon;
};

export const StatusLikeBurstIcon = likeBurstIcon('regular');
export const StatusLikeBurstActiveIcon = likeBurstIcon('fill');
