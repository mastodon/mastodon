import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import {
  deleteScheduledStatus,
  editScheduledStatus,
} from 'mastodon/actions/scheduled_statuses';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  editTitle: {
    id: 'confirmations.scheduled_status.edit.title',
    defaultMessage: 'Edit scheduled post?',
  },
  editMessage: {
    id: 'confirmations.scheduled_status.edit.message',
    defaultMessage:
      'This removes the scheduled post and opens it in the composer.',
  },
  editConfirm: {
    id: 'confirmations.scheduled_status.edit.confirm',
    defaultMessage: 'Edit post',
  },
  deleteTitle: {
    id: 'confirmations.scheduled_status.delete.title',
    defaultMessage: 'Delete scheduled post?',
  },
  deleteMessage: {
    id: 'confirmations.scheduled_status.delete.message',
    defaultMessage: 'Are you sure you want to delete this scheduled post?',
  },
  deleteConfirm: {
    id: 'confirmations.scheduled_status.delete.confirm',
    defaultMessage: 'Delete',
  },
});

export const ConfirmScheduledStatusModal: React.FC<
  {
    action: 'delete' | 'edit';
    scheduledStatus: {
      id: string;
      params: Record<string, unknown>;
      scheduled_at: string;
      media_attachments?: Record<string, unknown>[];
    };
  } & BaseConfirmationModalProps
> = ({ action, scheduledStatus, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const handleConfirm = useCallback(() => {
    if (action === 'edit') {
      return dispatch(editScheduledStatus(scheduledStatus)).then(() => undefined);
    }

    return dispatch(deleteScheduledStatus(scheduledStatus.id)).then(
      () => undefined,
    );
  }, [action, dispatch, scheduledStatus]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(
        action === 'edit' ? messages.editTitle : messages.deleteTitle,
      )}
      message={intl.formatMessage(
        action === 'edit' ? messages.editMessage : messages.deleteMessage,
      )}
      confirm={intl.formatMessage(
        action === 'edit' ? messages.editConfirm : messages.deleteConfirm,
      )}
      onConfirm={handleConfirm}
      onClose={onClose}
    />
  );
};
