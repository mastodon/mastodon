import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router';

import { deleteBookmarkFolder } from 'mastodon/actions/bookmark_folders_typed';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  deleteBookmarkFolderTitle: {
    id: 'confirmations.delete_bookmark_folder.title',
    defaultMessage: 'Delete bookmark folder?',
  },
  deleteBookmarkFolderMessage: {
    id: 'confirmations.delete_bookmark_folder.message',
    defaultMessage:
      'Are you sure you want to permanently delete this bookmark folder?',
  },
  deleteBookmarkFolderConfirm: {
    id: 'confirmations.delete_bookmark_folder.confirm',
    defaultMessage: 'Delete',
  },
});

export const ConfirmDeleteBookmarkFolderModal: React.FC<
  {
    id: string;
  } & BaseConfirmationModalProps
> = ({ id, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();

  const onConfirm = useCallback(() => {
    void dispatch(deleteBookmarkFolder({ id }));
    history.push('/bookmarks/folders');
  }, [dispatch, history, id]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.deleteBookmarkFolderTitle)}
      message={intl.formatMessage(messages.deleteBookmarkFolderMessage)}
      confirm={intl.formatMessage(messages.deleteBookmarkFolderConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
