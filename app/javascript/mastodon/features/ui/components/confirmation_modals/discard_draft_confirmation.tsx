import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { replyCompose } from 'mastodon/actions/compose';
import { editStatus } from 'mastodon/actions/statuses';
import type { Status } from 'mastodon/models/status';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  discardDraftTitle: {
    id: 'confirmations.discard_draft.title',
    defaultMessage: 'Discard your draft post?',
  },
  discardPostDraftMessage: {
    id: 'confirmations.discard_draft.post_message',
    defaultMessage:
      'Continuing will discard the post you are currently composing.',
  },
  discardEditDraftMessage: {
    id: 'confirmations.discard_draft.edit_message',
    defaultMessage:
      'Continuing will discard any changes you have made to the post you are currently editing.',
  },
  discardDraftConfirm: {
    id: 'confirmations.discard_draft.confirm',
    defaultMessage: 'Discard and continue',
  },
  discardDraftCancel: {
    id: 'confirmations.discard_draft.cancel',
    defaultMessage: 'Resume draft',
  },
});

const DiscardDraftConfirmationModal: React.FC<
  {
    onConfirm: () => void;
  } & BaseConfirmationModalProps
> = ({ onConfirm, onClose }) => {
  const intl = useIntl();
  const isEditing = useAppSelector((state) => !!state.compose.get('id'));

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.discardDraftTitle)}
      message={intl.formatMessage(
        isEditing
          ? messages.discardEditDraftMessage
          : messages.discardPostDraftMessage,
      )}
      confirm={intl.formatMessage(messages.discardDraftConfirm)}
      cancel={intl.formatMessage(messages.discardDraftCancel)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};

export const ConfirmReplyModal: React.FC<
  {
    status: Status;
  } & BaseConfirmationModalProps
> = ({ status, onClose }) => {
  const dispatch = useAppDispatch();

  const onConfirm = useCallback(() => {
    dispatch(replyCompose(status));
  }, [dispatch, status]);

  return (
    <DiscardDraftConfirmationModal onConfirm={onConfirm} onClose={onClose} />
  );
};

export const ConfirmEditStatusModal: React.FC<
  {
    statusId: string;
  } & BaseConfirmationModalProps
> = ({ statusId, onClose }) => {
  const dispatch = useAppDispatch();

  const onConfirm = useCallback(() => {
    dispatch(editStatus(statusId));
  }, [dispatch, statusId]);

  return (
    <DiscardDraftConfirmationModal onConfirm={onConfirm} onClose={onClose} />
  );
};
