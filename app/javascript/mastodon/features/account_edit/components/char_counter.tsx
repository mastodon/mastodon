import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { polymorphicForwardRef } from '@/types/polymorphic';

import classes from '../styles.module.scss';

export const CharCounter = polymorphicForwardRef<
  'p',
  { currentLength: number; maxLength: number }
>(({ currentLength, maxLength, as: Component = 'p' }, ref) => (
  <Component
    ref={ref}
    className={classNames(
      classes.counter,
      currentLength > maxLength && classes.counterError,
    )}
  >
    <FormattedMessage
      id='account_edit.char_counter'
      defaultMessage='{currentLength}/{maxLength} characters'
      values={{ currentLength, maxLength }}
    />
  </Component>
));
CharCounter.displayName = 'CharCounter';
