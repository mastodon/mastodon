import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router';

import { removeColumn } from 'mastodon/actions/columns';
import { deleteList } from 'mastodon/actions/lists';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  deleteListTitle: {
    id: 'confirmations.delete_list.title',
    defaultMessage: 'Delete list?',
  },
  deleteListMessage: {
    id: 'confirmations.delete_list.message',
    defaultMessage: 'Are you sure you want to permanently delete this list?',
  },
  deleteListConfirm: {
    id: 'confirmations.delete_list.confirm',
    defaultMessage: 'Delete',
  },
});

export const ConfirmDeleteListModal: React.FC<
  {
    listId: string;
    columnId: string;
  } & BaseConfirmationModalProps
> = ({ listId, columnId, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();

  const onConfirm = useCallback(() => {
    dispatch(deleteList(listId));

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      history.push('/lists');
    }
  }, [dispatch, history, columnId, listId]);

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
