import { useCallback, useState } from 'react';
import * as React from 'react';

import { TransitionMotion, spring } from 'react-motion';

import { reduceMotion } from '../initial_state';

import { ShortNumber } from './short_number';

const obfuscatedCount = (count: number) => {
  if (count < 0) {
    return 0;
  } else if (count <= 1) {
    return count;
  } else {
    return '1+';
  }
};

interface Props {
  value: number;
  obfuscate?: boolean;
}
export const AnimatedNumber: React.FC<Props> = ({ value, obfuscate }) => {
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
    return obfuscate ? (
      <>{obfuscatedCount(value)}</>
    ) : (
      <ShortNumber value={value} />
    );
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
              {obfuscate ? (
                obfuscatedCount(data as number)
              ) : (
                <ShortNumber value={data as number} />
              )}
            </span>
          ))}
        </span>
      )}
    </TransitionMotion>
  );
};
