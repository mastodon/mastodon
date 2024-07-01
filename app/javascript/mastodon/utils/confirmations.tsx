import { defineMessages, FormattedMessage } from 'react-intl';
import type { IntlShape } from 'react-intl';

import { unfollowAccount } from 'mastodon/actions/accounts';
import { removeColumn } from 'mastodon/actions/columns';
import { replyCompose } from 'mastodon/actions/compose';
import { deleteList } from 'mastodon/actions/lists';
import { openModal } from 'mastodon/actions/modal';
import { clearNotifications } from 'mastodon/actions/notification_groups';
import { deleteStatus, editStatus } from 'mastodon/actions/statuses';
import { browserHistory } from 'mastodon/components/router';
import type { Account } from 'mastodon/models/account';
import type { Status } from 'mastodon/models/status';
import type { AppDispatch } from 'mastodon/store';
import { logOut } from 'mastodon/utils/log_out';

const messages = defineMessages({
  deleteAndRedraftTitle: {
    id: 'confirmations.redraft.title',
    defaultMessage: 'Delete & redraft post?',
  },
  deleteAndRedraftMessage: {
    id: 'confirmations.redraft.message',
    defaultMessage:
      'Are you sure you want to delete this status and re-draft it? Favorites and boosts will be lost, and replies to the original post will be orphaned.',
  },
  deleteAndRedraftConfirm: {
    id: 'confirmations.redraft.confirm',
    defaultMessage: 'Delete & redraft',
  },
  deleteTitle: {
    id: 'confirmations.delete.title',
    defaultMessage: 'Delete post?',
  },
  deleteMessage: {
    id: 'confirmations.delete.message',
    defaultMessage: 'Are you sure you want to delete this status?',
  },
  deleteConfirm: {
    id: 'confirmations.delete.confirm',
    defaultMessage: 'Delete',
  },
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
  replyTitle: {
    id: 'confirmations.reply.title',
    defaultMessage: 'Overwrite post?',
  },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: {
    id: 'confirmations.reply.message',
    defaultMessage:
      'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?',
  },
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
  logoutTitle: { id: 'confirmations.logout.title', defaultMessage: 'Log out?' },
  logoutMessage: {
    id: 'confirmations.logout.message',
    defaultMessage: 'Are you sure you want to log out?',
  },
  logoutConfirm: {
    id: 'confirmations.logout.confirm',
    defaultMessage: 'Log out',
  },
  clearTitle: {
    id: 'notifications.clear_title',
    defaultMessage: 'Clear notifications?',
  },
  clearMessage: {
    id: 'notifications.clear_confirmation',
    defaultMessage:
      'Are you sure you want to permanently clear all your notifications?',
  },
  clearConfirm: {
    id: 'notifications.clear',
    defaultMessage: 'Clear notifications',
  },
  unfollowTitle: {
    id: 'confirmations.unfollow.title',
    defaultMessage: 'Unfollow user?',
  },
  unfollowConfirm: {
    id: 'confirmations.unfollow.confirm',
    defaultMessage: 'Unfollow',
  },
});

export const confirmDeleteStatus = (
  dispatch: AppDispatch,
  intl: IntlShape,
  statusId: string,
  withRedraft: boolean,
) => {
  dispatch(
    openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(
          withRedraft ? messages.deleteAndRedraftTitle : messages.deleteTitle,
        ),
        message: intl.formatMessage(
          withRedraft
            ? messages.deleteAndRedraftMessage
            : messages.deleteMessage,
        ),
        confirm: intl.formatMessage(
          withRedraft
            ? messages.deleteAndRedraftConfirm
            : messages.deleteConfirm,
        ),
        onConfirm: () => {
          dispatch(deleteStatus(statusId, withRedraft));
        },
      },
    }),
  );
};

export const confirmDeleteList = (
  dispatch: AppDispatch,
  intl: IntlShape,
  listId: string,
  columnId: string,
) => {
  dispatch(
    openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.deleteListTitle),
        message: intl.formatMessage(messages.deleteListMessage),
        confirm: intl.formatMessage(messages.deleteListConfirm),
        onConfirm: () => {
          dispatch(deleteList(listId));

          if (columnId) {
            dispatch(removeColumn(columnId));
          } else {
            browserHistory.push('/lists');
          }
        },
      },
    }),
  );
};

export const confirmReply = (
  dispatch: AppDispatch,
  intl: IntlShape,
  status: Status,
) => {
  dispatch(
    openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.replyTitle),
        message: intl.formatMessage(messages.replyMessage),
        confirm: intl.formatMessage(messages.replyConfirm),
        onConfirm: () => {
          dispatch(replyCompose(status));
        },
      },
    }),
  );
};

export const confirmEdit = (
  dispatch: AppDispatch,
  intl: IntlShape,
  statusId: string,
) => {
  dispatch(
    openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.editTitle),
        message: intl.formatMessage(messages.editMessage),
        confirm: intl.formatMessage(messages.editConfirm),
        onConfirm: () => {
          dispatch(editStatus(statusId));
        },
      },
    }),
  );
};

export const confirmUnfollow = (
  dispatch: AppDispatch,
  intl: IntlShape,
  account: Account,
) => {
  dispatch(
    openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.unfollowTitle),
        message: (
          <FormattedMessage
            id='confirmations.unfollow.message'
            defaultMessage='Are you sure you want to unfollow {name}?'
            values={{ name: <strong>@{account.acct}</strong> }}
          />
        ),
        confirm: intl.formatMessage(messages.unfollowConfirm),
        onConfirm: () => {
          dispatch(unfollowAccount(account.id));
        },
      },
    }),
  );
};

export const confirmClearNotifications = (
  dispatch: AppDispatch,
  intl: IntlShape,
) => {
  dispatch(
    openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.clearTitle),
        message: intl.formatMessage(messages.clearMessage),
        confirm: intl.formatMessage(messages.clearConfirm),
        onConfirm: () => {
          void dispatch(clearNotifications());
        },
      },
    }),
  );
};

export const confirmLogOut = (dispatch: AppDispatch, intl: IntlShape) => {
  dispatch(
    openModal({
      modalType: 'CONFIRM',
      modalProps: {
        title: intl.formatMessage(messages.logoutTitle),
        message: intl.formatMessage(messages.logoutMessage),
        confirm: intl.formatMessage(messages.logoutConfirm),
        closeWhenConfirm: false,
        onConfirm: () => {
          logOut();
        },
      },
    }),
  );
};
