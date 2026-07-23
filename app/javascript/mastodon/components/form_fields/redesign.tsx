import classNames from 'classnames';

import type { Merge } from 'type-fest';

import classes from './redesign.module.scss';
import {
  Toggle as OldToggle,
  ToggleField as OldToggleField,
} from './toggle_field';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ToggleComponent<T extends React.JSXElementConstructor<any>> = React.FC<
  Merge<
    React.ComponentProps<T>,
    {
      size?: 'sm' | 'lg';
    }
  >
>;

export const Toggle: ToggleComponent<typeof OldToggle> = ({
  className,
  size,
  ...props
}) => (
  <OldToggle
    {...props}
    className={classNames(
      className,
      classes.toggle,
      size === 'sm' && classes.toggleSmall,
    )}
  />
);

export const ToggleField: ToggleComponent<typeof OldToggleField> = ({
  className,
  size,
  ...props
}) => (
  <OldToggleField
    {...props}
    className={classNames(
      className,
      classes.toggle,
      size === 'sm' && classes.toggleSmall,
    )}
  />
);
