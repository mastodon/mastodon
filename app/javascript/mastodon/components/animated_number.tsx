import { useCallback, useState } from 'react';

import { TransitionMotion, spring } from 'react-motion';

import { reduceMotion } from '../initial_state';

import { ShortNumber } from './short_number';

interface Props {
  value: number;
}
export const AnimatedNumber: React.FC<Props> = ({ value }) => {
  const [previousValue, setPreviousValue] = useState(value);
  const [direction, setDirection] = useState<1 | -1>(1);

  if (previousValue !== value) {
    setPreviousValue(value);
    setDirection(value > previousValue ? 1 : -1);
  }

  const willEnter = useCallback(() => ({ y: -1 * direction }), [direction]);
  const willLeave = useCallback(
    () => ({ y: spring(1 * direction, { damping: 35, stiffness: 400 }) }),
    [direction],
  );

  if (reduceMotion) {
    return <ShortNumber value={value} />;
  }

  const styles = [
    {
      key: `${value}`,
      data: value,
      style: { y: spring(0, { damping: 35, stiffness: 400 }) },
    },
  ];

  return (
    <TransitionMotion
      styles={styles}
      willEnter={willEnter}
      willLeave={willLeave}
    >
      {(items) => (
        <span className='animated-number'>
          {items.map(({ key, data, style }) => (
            <span
              key={key}
              style={{
                position: direction * style.y > 0 ? 'absolute' : 'static',
                transform: `translateY(${style.y * 100}%)`,
              }}
            >
              <ShortNumber value={data as number} />
            </span>
          ))}
        </span>
      )}
    </TransitionMotion>
  );
};
