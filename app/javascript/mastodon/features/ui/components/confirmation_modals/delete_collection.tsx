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
    defaultMessage: 'Delete collection?',
  },
  deleteListMessage: {
    id: 'confirmations.delete_collection.message',
    defaultMessage:
      'Are you sure you want to permanently delete this collection?',
  },
  deleteListConfirm: {
    id: 'confirmations.delete_collection.confirm',
    defaultMessage: 'Delete',
  },
});

export const ConfirmDeleteCollectionModal: React.FC<
  {
    collectionId: string;
  } & BaseConfirmationModalProps
> = ({ collectionId, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();

  const onConfirm = useCallback(() => {
    void dispatch(deleteCollection({ collectionId }));
    history.push('/collections');
  }, [dispatch, history, collectionId]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.deleteListTitle)}
      message={intl.formatMessage(messages.deleteListMessage)}
      confirm={intl.formatMessage(messages.deleteListConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
