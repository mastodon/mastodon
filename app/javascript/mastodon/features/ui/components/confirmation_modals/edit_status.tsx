import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { editStatus } from 'mastodon/actions/statuses';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  editTitle: {
    id: 'confirmations.edit.title',
    defaultMessage: 'Overwrite post?',
  },
  editConfirm: { id: 'confirmations.edit.confirm', defaultMessage: 'Edit' },
  editMessage: {
    id: 'confirmations.edit.message',
    defaultMessage:
      'Editing now will overwrite the message you are currently composing. Are you sure you want to proceed?',
  },
});

export const ConfirmEditStatusModal: React.FC<
  {
    statusId: string;
  } & BaseConfirmationModalProps
> = ({ statusId, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const onConfirm = useCallback(() => {
    dispatch(editStatus(statusId));
  }, [dispatch, statusId]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.editTitle)}
      message={intl.formatMessage(messages.editMessage)}
      confirm={intl.formatMessage(messages.editConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
