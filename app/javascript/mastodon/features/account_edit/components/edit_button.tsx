import type { FC, MouseEventHandler } from 'react';

import classNames from 'classnames';

import { Button } from '@/mastodon/components/button';
import { IconButton } from '@/mastodon/components/icon_button';
import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';

import classes from '../styles.module.scss';

export interface EditButtonProps {
  onClick: MouseEventHandler;
  label: string;
  icon?: boolean;
  disabled?: boolean;
}

export const EditButton: FC<EditButtonProps> = ({
  onClick,
  label,
  icon = false,
  disabled,
}) => {
  if (icon) {
    return (
      <EditIconButton title={label} onClick={onClick} disabled={disabled} />
    );
  }

  return (
    <Button
      className={classes.editButton}
      onClick={onClick}
      disabled={disabled}
    >
      {label}
    </Button>
  );
};

export const EditIconButton: FC<{
  onClick: MouseEventHandler;
  title: string;
  disabled?: boolean;
}> = ({ title, onClick, disabled }) => (
  <IconButton
    icon='pencil'
    iconComponent={EditIcon}
    onClick={onClick}
    className={classes.editButton}
    title={title}
    disabled={disabled}
  />
);

export const DeleteIconButton: FC<{
  onClick: MouseEventHandler;
  label: string;
  disabled?: boolean;
}> = ({ onClick, label, disabled }) => (
  <IconButton
    icon='delete'
    iconComponent={DeleteIcon}
    onClick={onClick}
    className={classNames(classes.editButton, classes.deleteButton)}
    title={label}
    disabled={disabled}
  />
);
