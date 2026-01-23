import type { ComponentPropsWithoutRef, ReactNode } from 'react';
import { forwardRef } from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import type { IconProp } from '../icon';
import { Icon } from '../icon';
import { IconButton } from '../icon_button';

import classes from './style.module.css';

type TagProps = {
  name: ReactNode;
  active?: boolean;
  icon?: IconProp;
} & ComponentPropsWithoutRef<'button'>;

export const Tag = forwardRef<HTMLButtonElement, TagProps>(
  ({ name, active, icon, className, ...props }, ref) => {
    if (!name) {
      return null;
    }
    return (
      <button
        {...props}
        type='button'
        ref={ref}
        className={classNames(className, classes.tag, active && classes.active)}
      >
        {icon && <Icon icon={icon} id='tag-icon' className={classes.icon} />}
        {typeof name === 'string' ? `#${name}` : name}
      </button>
    );
  },
);
Tag.displayName = 'Tag';

export const EditableTag = forwardRef<
  HTMLSpanElement,
  TagProps & { onRemove: () => void }
>(({ name, active, icon, className, ...props }, ref) => {
  const intl = useIntl();

  if (!name) {
    return null;
  }
  return (
    <span
      {...props}
      ref={ref}
      className={classNames(className, classes.tag, active && classes.active)}
    >
      {icon && <Icon icon={icon} id='tag-icon' className={classes.icon} />}
      {typeof name === 'string' ? `#${name}` : name}
      <IconButton
        className={classes.closeButton}
        iconComponent={CloseIcon}
        icon='remove'
        title={intl.formatMessage({
          id: 'tag.remove',
          defaultMessage: 'Remove',
        })}
      />
    </span>
  );
});
EditableTag.displayName = 'EditableTag';
