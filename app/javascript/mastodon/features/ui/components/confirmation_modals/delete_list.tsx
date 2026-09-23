import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { useHistory } from 'react-router';

import { isRedesignEnabled } from '@/mastodon/utils/environment';
import { removeColumn } from 'mastodon/actions/columns';
import { deleteList } from 'mastodon/actions/lists';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const legacyMessages = defineMessages({
  deleteTitle: {
    id: 'confirmations.delete_list.title',
    defaultMessage: 'Delete list?',
  },
  deleteMessage: {
    id: 'confirmations.delete_list.message',
    defaultMessage: 'Are you sure you want to permanently delete this list?',
  },
  deleteConfirm: {
    id: 'confirmations.delete_list.confirm',
    defaultMessage: 'Delete',
  },
});

const redesignMessages = defineMessages({
  deleteTitle: {
    id: 'confirmations.delete_custom_feed.title',
    defaultMessage: 'Delete custom feed?',
  },
  deleteMessage: {
    id: 'confirmations.delete_custom_feed.message',
    defaultMessage:
      'Are you sure you want to permanently delete this custom feed?',
  },
  deleteConfirm: {
    id: 'confirmations.delete_list.confirm',
    defaultMessage: 'Delete',
  },
});

const messages = isRedesignEnabled() ? redesignMessages : legacyMessages;

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
      title={intl.formatMessage(messages.deleteTitle)}
      message={intl.formatMessage(messages.deleteMessage)}
      confirm={intl.formatMessage(messages.deleteConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
