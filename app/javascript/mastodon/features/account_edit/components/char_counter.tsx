import { polymorphicForwardRef } from '@/types/polymorphic';

import classes from '../styles.module.scss';

export const CharCounter = polymorphicForwardRef<
  'p',
  { currentLength: number; maxLength: number }
>(({ currentLength, maxLength, as: Component = 'p' }, ref) => (
  <Component ref={ref} className={classes.counter}>
    {currentLength}/{maxLength} characters
  </Component>
));
CharCounter.displayName = 'CharCounter';
