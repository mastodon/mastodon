import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router';

import { deleteCollection } from 'mastodon/reducers/slices/collections';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  deleteListTitle: {
    id: 'confirmations.delete_collection.title',
    defaultMessage: 'Delete "{name}"?',
  },
  deleteListMessage: {
    id: 'confirmations.delete_collection.message',
    defaultMessage: 'This action cannot be undone.',
  },
  deleteListConfirm: {
    id: 'confirmations.delete_collection.confirm',
    defaultMessage: 'Delete',
  },
});

export const ConfirmDeleteCollectionModal: React.FC<
  {
    id: string;
    name: string;
  } & BaseConfirmationModalProps
> = ({ id, name, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();

  const onConfirm = useCallback(() => {
    void dispatch(deleteCollection({ collectionId: id }));
    history.push('/collections');
  }, [dispatch, history, id]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.deleteListTitle, {
        name,
      })}
      message={intl.formatMessage(messages.deleteListMessage)}
      confirm={intl.formatMessage(messages.deleteListConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
