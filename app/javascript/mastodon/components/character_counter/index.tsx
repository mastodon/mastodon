import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { polymorphicForwardRef } from '@/types/polymorphic';

import classes from './styles.module.scss';

export const CharacterCounter = polymorphicForwardRef<
  'span',
  { currentLength: number; maxLength: number; recommended?: boolean }
>(
  (
    { currentLength, maxLength, as: Component = 'span', recommended = false },
    ref,
  ) => (
    <Component
      ref={ref}
      className={classNames(
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
  ),
);
CharacterCounter.displayName = 'CharCounter';
