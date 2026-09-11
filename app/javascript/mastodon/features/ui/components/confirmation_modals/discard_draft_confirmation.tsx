import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { replyCompose } from 'mastodon/actions/compose';
import { editStatus } from 'mastodon/actions/statuses';
import type { Status } from 'mastodon/models/status';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const editMessages = defineMessages({
  title: {
    id: 'confirmations.discard_draft.edit.title',
    defaultMessage: 'Discard changes to your post?',
  },
  message: {
    id: 'confirmations.discard_draft.edit.message',
    defaultMessage:
      'Continuing will discard any changes you have made to the post you are currently editing.',
  },
  cancel: {
    id: 'confirmations.discard_draft.edit.cancel',
    defaultMessage: 'Resume editing',
  },
});

const postMessages = defineMessages({
  title: {
    id: 'confirmations.discard_draft.post.title',
    defaultMessage: 'Discard your draft post?',
  },
  message: {
    id: 'confirmations.discard_draft.post.message',
    defaultMessage:
      'Continuing will discard the post you are currently composing.',
  },
  cancel: {
    id: 'confirmations.discard_draft.post.cancel',
    defaultMessage: 'Resume draft',
  },
});

const messages = defineMessages({
  confirm: {
    id: 'confirmations.discard_draft.confirm',
    defaultMessage: 'Discard and continue',
  },
});

const DiscardDraftConfirmationModal: React.FC<
  {
    onConfirm: () => void;
  } & BaseConfirmationModalProps
> = ({ onConfirm, onClose }) => {
  const intl = useIntl();
  const isEditing = useAppSelector((state) => !!state.compose.get('id'));

  const contextualMessages = isEditing ? editMessages : postMessages;

  return (
    <ConfirmationModal
      title={intl.formatMessage(contextualMessages.title)}
      message={intl.formatMessage(contextualMessages.message)}
      cancel={intl.formatMessage(contextualMessages.cancel)}
      confirm={intl.formatMessage(messages.confirm)}
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
