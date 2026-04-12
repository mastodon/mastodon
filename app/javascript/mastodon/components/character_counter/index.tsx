import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { length } from 'stringz';

import { polymorphicForwardRef } from '@/types/polymorphic';

import classes from './styles.module.scss';

interface CharacterCounterProps {
  currentString: string;
  maxLength: number;
  recommended?: boolean;
}

export const CharacterCounter = polymorphicForwardRef<
  'span',
  CharacterCounterProps
>(
  (
    {
      currentString,
      maxLength,
      as: Component = 'span',
      recommended = false,
      className,
      ...props
    },
    ref,
  ) => {
    const currentLength = length(currentString);
    return (
      <Component
        {...props}
        ref={ref}
        className={classNames(
          className,
          classes.counter,
          currentLength > maxLength && !recommended && classes.counterError,
        )}
      >
        {recommended ? (
          <FormattedMessage
            id='character_counter.recommended'
            defaultMessage='{currentLength}/{maxLength} recommended characters'
            values={{ currentLength, maxLength }}
          />
        ) : (
          <FormattedMessage
            id='character_counter.required'
            defaultMessage='{currentLength}/{maxLength} characters'
            values={{ currentLength, maxLength }}
          />
        )}
      </Component>
    );
  },
);
CharacterCounter.displayName = 'CharCounter';
