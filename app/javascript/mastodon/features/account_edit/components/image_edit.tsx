import { useMemo } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import type { OffsetValue } from 'react-overlays/esm/usePopper';

import { Dropdown } from '@/mastodon/components/dropdown_menu';
import { IconButton } from '@/mastodon/components/icon_button';
import type { MenuItem } from '@/mastodon/models/dropdown_menu';
import AddIcon from '@/material-icons/400-24px/add.svg?react';
import DeleteIcon from '@/material-icons/400-24px/delete.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import CameraIcon from '@/material-icons/400-24px/photo_camera.svg?react';
import ReplaceImageIcon from '@/material-icons/400-24px/replace_image.svg?react';

const messages = defineMessages({
  add: {
    id: 'account_edit.image_edit.add_button',
    defaultMessage: 'Add image',
  },
  replace: {
    id: 'account_edit.image_edit.replace_button',
    defaultMessage: 'Replace image',
  },
  altAdd: {
    id: 'account_edit.image_edit.alt_add_button',
    description: 'Alt is short for "alternative".',
    defaultMessage: 'Add alt text',
  },
  altEdit: {
    id: 'account_edit.image_edit.alt_edit_button',
    description: 'Alt is short for "alternative".',
    defaultMessage: 'Edit alt text',
  },
  remove: {
    id: 'account_edit.image_edit.remove_button',
    defaultMessage: 'Remove image',
  },
});

export const AccountImageEdit: FC<{
  className?: string;
  add?: boolean;
  hasAltText?: boolean;
}> = ({ className, add = false, hasAltText = false }) => {
  const intl = useIntl();
  const items = useMemo(
    () =>
      [
        {
          text: intl.formatMessage(messages.replace),
          action: () => null,
          icon: ReplaceImageIcon,
        },
        {
          text: intl.formatMessage(
            hasAltText ? messages.altEdit : messages.altAdd,
          ),
          action: () => null,
          icon: hasAltText ? EditIcon : AddIcon,
        },
        null,
        {
          text: intl.formatMessage(messages.remove),
          action: () => null,
          icon: DeleteIcon,
          dangerous: true,
        },
      ] satisfies MenuItem[],
    [hasAltText, intl],
  );

  const button = (
    <IconButton
      title={intl.formatMessage(messages.add)}
      icon='camera'
      iconComponent={CameraIcon}
      className={className}
    />
  );

  if (add) {
    return button;
  }

  return (
    <Dropdown items={items} placement='bottom-start' offset={popperOffset}>
      {button}
    </Dropdown>
  );
};

const popperOffset = [-4, 10] as OffsetValue;
