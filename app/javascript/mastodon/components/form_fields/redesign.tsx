import classNames from 'classnames';

import classes from './redesign.module.scss';
import {
  Toggle as OldToggle,
  ToggleField as OldToggleField,
} from './toggle_field';

export const Toggle: React.FC<React.ComponentProps<typeof OldToggle>> = ({
  className,
  ...props
}) => (
  <OldToggle {...props} className={classNames(className, classes.toggle)} />
);

export const ToggleField: React.FC<
  React.ComponentProps<typeof OldToggleField>
> = ({ className, ...props }) => (
  <OldToggleField
    {...props}
    className={classNames(className, classes.toggle)}
  />
);
