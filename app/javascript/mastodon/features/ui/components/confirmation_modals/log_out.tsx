import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { logOut } from 'mastodon/utils/log_out';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  logoutTitle: { id: 'confirmations.logout.title', defaultMessage: 'Log out?' },
  logoutMessage: {
    id: 'confirmations.logout.message',
    defaultMessage: 'Are you sure you want to log out?',
  },
  logoutConfirm: {
    id: 'confirmations.logout.confirm',
    defaultMessage: 'Log out',
  },
});

export const ConfirmLogOutModal: React.FC<BaseConfirmationModalProps> = ({
  onClose,
}) => {
  const intl = useIntl();

  const onConfirm = useCallback(() => {
    void logOut();
  }, []);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.logoutTitle)}
      message={intl.formatMessage(messages.logoutMessage)}
      confirm={intl.formatMessage(messages.logoutConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
