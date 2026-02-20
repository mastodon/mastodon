import type { FC, MouseEventHandler } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { defineMessages, useIntl } from 'react-intl';

import { Button } from '@/mastodon/components/button';
import { IconButton } from '@/mastodon/components/icon_button';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';

import classes from '../styles.module.scss';

const messages = defineMessages({
  add: {
    id: 'account_edit.button.add',
    defaultMessage: 'Add {item}',
  },
  edit: {
    id: 'account_edit.button.edit',
    defaultMessage: 'Edit {item}',
  },
});

export interface EditButtonProps {
  onClick: MouseEventHandler;
  item: string | MessageDescriptor;
  edit?: boolean;
  icon?: boolean;
}

export const EditButton: FC<EditButtonProps> = ({
  onClick,
  item,
  edit = false,
  icon = edit,
}) => {
  const intl = useIntl();

  const itemText = typeof item === 'string' ? item : intl.formatMessage(item);
  const label = intl.formatMessage(messages[edit ? 'edit' : 'add'], {
    item: itemText,
  });

  if (icon) {
    return <EditIconButton title={label} onClick={onClick} />;
  }

  return (
    <Button className={classes.editButton} onClick={onClick}>
      {label}
    </Button>
  );
};

export const EditIconButton: FC<{
  onClick: MouseEventHandler;
  title: string;
}> = ({ title, onClick }) => (
  <IconButton
    icon='pencil'
    iconComponent={EditIcon}
    onClick={onClick}
    className={classes.editButton}
    title={title}
  />
);
