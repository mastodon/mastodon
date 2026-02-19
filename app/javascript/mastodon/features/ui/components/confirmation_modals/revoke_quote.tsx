import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { revokeQuote } from 'mastodon/actions/interactions_typed';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  revokeQuoteTitle: {
    id: 'confirmations.revoke_quote.title',
    defaultMessage: 'Remove post?',
  },
  revokeQuoteMessage: {
    id: 'confirmations.revoke_quote.message',
    defaultMessage: 'This action cannot be undone.',
  },
  revokeQuoteConfirm: {
    id: 'confirmations.revoke_quote.confirm',
    defaultMessage: 'Remove post',
  },
});

export const ConfirmRevokeQuoteModal: React.FC<
  {
    statusId: string;
    quotedStatusId: string;
  } & BaseConfirmationModalProps
> = ({ statusId, quotedStatusId, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const onConfirm = useCallback(() => {
    void dispatch(revokeQuote({ quotedStatusId, statusId }));
  }, [dispatch, statusId, quotedStatusId]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.revokeQuoteTitle)}
      message={intl.formatMessage(messages.revokeQuoteMessage)}
      confirm={intl.formatMessage(messages.revokeQuoteConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
