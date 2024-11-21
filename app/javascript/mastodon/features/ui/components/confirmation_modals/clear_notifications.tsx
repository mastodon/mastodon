import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { clearNotifications } from 'mastodon/actions/notification_groups';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
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
});

export const ConfirmClearNotificationsModal: React.FC<
  BaseConfirmationModalProps
> = ({ onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const onConfirm = useCallback(() => {
    void dispatch(clearNotifications());
  }, [dispatch]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.clearTitle)}
      message={intl.formatMessage(messages.clearMessage)}
      confirm={intl.formatMessage(messages.clearConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
