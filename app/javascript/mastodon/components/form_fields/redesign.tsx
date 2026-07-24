import classNames from 'classnames';

import type { Merge } from 'type-fest';

import { Icon } from '../icon';
import type { IconProp } from '../icon';

import { RadioButtonField as OldRadioButtonField } from './radio_button_field';
import classes from './redesign.module.scss';
import {
  TextInput as OldTextInput,
  TextInputField as OldTextInputField,
} from './text_input_field';
import {
  Toggle as OldToggle,
  ToggleField as OldToggleField,
} from './toggle_field';

type RedesignComponent<
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  T extends React.JSXElementConstructor<any>,
  P = object,
> = React.FC<Merge<React.ComponentProps<T>, P>>;

// Radio button field

interface RadioButtonProps {
  icon?: IconProp | null;
  iconClassName?: string;
}

export const RadioButtonField: RedesignComponent<
  typeof OldRadioButtonField,
  RadioButtonProps
> = ({ className, icon, iconClassName, wrapperClassName, ...props }) => (
  <OldRadioButtonField
    {...props}
    className={classNames(className, classes.radio)}
    wrapperClassName={classNames(wrapperClassName, classes.radioWrapper)}
  >
    {icon && (
      <Icon
        id='checked'
        icon={icon}
        className={classNames(classes.icon, iconClassName)}
      />
    )}
  </OldRadioButtonField>
);

// Text field

export const TextInputField: RedesignComponent<typeof OldTextInputField> = ({
  className,
  wrapperClassName,
  ...props
}) => (
  <OldTextInputField
    {...props}
    className={classNames(className, classes.input)}
    wrapperClassName={classNames(wrapperClassName, classes.inputWrapper)}
  />
);

export const TextInput: RedesignComponent<typeof OldTextInput> = ({
  className,
  ...props
}) => (
  <OldTextInput {...props} className={classNames(className, classes.input)} />
);

// Toggles

interface ToggleProps {
  size?: 'sm' | 'lg';
}

export const Toggle: RedesignComponent<typeof OldToggle, ToggleProps> = ({
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

export const ToggleField: RedesignComponent<
  typeof OldToggleField,
  ToggleProps
> = ({ className, size, ...props }) => (
  <OldToggleField
    {...props}
    className={classNames(
      className,
      classes.toggle,
      size === 'sm' && classes.toggleSmall,
    )}
    size={size === 'sm' ? 14 : 20}
  />
);
