import type { FC, MouseEventHandler } from 'react';

import { PencilIcon, TrashIcon } from '@phosphor-icons/react';

import { Button, IconButton } from '@/mastodon/components/button/redesign';

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
    <Button onClick={onClick} disabled={disabled} size='sm'>
      {label}
    </Button>
  );
};

export const EditIconButton: FC<{
  onClick: MouseEventHandler;
  title: string;
  disabled?: boolean;
}> = ({ title, onClick, disabled }) => (
  <IconButton icon={PencilIcon} onClick={onClick} disabled={disabled} size='sm'>
    {title}
  </IconButton>
);

export const DeleteIconButton: FC<{
  onClick: MouseEventHandler;
  label: string;
  disabled?: boolean;
}> = ({ onClick, label, disabled }) => (
  <IconButton
    icon={TrashIcon}
    onClick={onClick}
    color='destructive'
    disabled={disabled}
    size='sm'
  >
    {label}
  </IconButton>
);
