import type { ComponentPropsWithoutRef, ReactNode } from 'react';
import { forwardRef } from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import type { OmitUnion } from '@/mastodon/utils/types';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import type { IconProp } from '../icon';
import { Icon } from '../icon';
import { IconButton } from '../icon_button';

import classes from './style.module.css';

export interface TagProps {
  name: ReactNode;
  active?: boolean;
  icon?: IconProp;
  className?: string;
  children?: ReactNode;
}

export const Tag = forwardRef<
  HTMLButtonElement,
  OmitUnion<ComponentPropsWithoutRef<'button'>, TagProps>
>(({ name, active, icon, className, children, ...props }, ref) => {
  if (!name) {
    return null;
  }
  return (
    <button
      {...props}
      type='button'
      ref={ref}
      className={classNames(className, classes.tag, active && classes.active)}
      aria-pressed={active}
    >
      {icon && <Icon icon={icon} id='tag-icon' className={classes.icon} />}
      {typeof name === 'string' ? `#${name}` : name}
      {children}
    </button>
  );
});
Tag.displayName = 'Tag';

export const EditableTag = forwardRef<
  HTMLSpanElement,
  OmitUnion<
    ComponentPropsWithoutRef<'span'>,
    TagProps & {
      onRemove: () => void;
      removeIcon?: IconProp;
    }
  >
>(
  (
    {
      name,
      active,
      icon,
      className,
      children,
      removeIcon = CloseIcon,
      onRemove,
      ...props
    },
    ref,
  ) => {
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
        {children}
        <IconButton
          className={classes.closeButton}
          iconComponent={removeIcon}
          onClick={onRemove}
          icon='remove'
          title={intl.formatMessage({
            id: 'tag.remove',
            defaultMessage: 'Remove',
          })}
        />
      </span>
    );
  },
);
EditableTag.displayName = 'EditableTag';
