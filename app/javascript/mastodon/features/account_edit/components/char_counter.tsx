import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { polymorphicForwardRef } from '@/types/polymorphic';

import classes from '../styles.module.scss';

export const CharCounter = polymorphicForwardRef<
  'p',
  { currentLength: number; maxLength: number; recommended?: boolean }
>(
  (
    { currentLength, maxLength, as: Component = 'p', recommended = false },
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
          id='account_edit.char_counter.recommended'
          defaultMessage='{currentLength}/{maxLength} recommended characters'
          values={{ currentLength, maxLength }}
        />
      ) : (
        <FormattedMessage
          id='account_edit.char_counter'
          defaultMessage='{currentLength}/{maxLength} characters'
          values={{ currentLength, maxLength }}
        />
      )}
    </Component>
  ),
);
CharCounter.displayName = 'CharCounter';
