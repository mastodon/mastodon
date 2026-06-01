import type { FC } from 'react';
import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { openModal } from '@/mastodon/actions/modal';
import { useAppDispatch } from '@/mastodon/store';

import { EditButton, DeleteIconButton } from './edit_button';

const messages = defineMessages({
  edit: {
    id: 'account_edit.field_actions.edit',
    defaultMessage: 'Edit field',
  },
  delete: {
    id: 'account_edit.field_actions.delete',
    defaultMessage: 'Delete field',
  },
});

export const AccountFieldActions: FC<{ id: string }> = ({ id }) => {
  const dispatch = useAppDispatch();
  const handleEdit = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_EDIT_FIELD_EDIT',
        modalProps: { fieldKey: id },
      }),
    );
  }, [dispatch, id]);
  const handleDelete = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_EDIT_FIELD_DELETE',
        modalProps: { fieldKey: id },
      }),
    );
  }, [dispatch, id]);

  const intl = useIntl();

  return (
    <>
      <EditButton
        label={intl.formatMessage(messages.edit)}
        icon
        onClick={handleEdit}
      />
      <DeleteIconButton
        label={intl.formatMessage(messages.delete)}
        onClick={handleDelete}
      />
    </>
  );
};
