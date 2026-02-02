import type { ComponentPropsWithoutRef } from 'react';

import classNames from 'classnames';

import { polymorphicForwardRef } from '@/types/polymorphic';

import classes from './form_stack.module.scss';

/**
 * A simple wrapper for providing consistent spacing to a group of form fields.
 */

export const FormStack = polymorphicForwardRef<
  'div',
  ComponentPropsWithoutRef<'div'>
>(({ as: Element = 'div', children, className, ...otherProps }, ref) => (
  <Element
    ref={ref}
    {...otherProps}
    className={classNames(className, classes.stack)}
  >
    {children}
  </Element>
));

FormStack.displayName = 'FormStack';
