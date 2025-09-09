import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { quoteCompose } from '@/mastodon/actions/compose_typed';
import { closeModal } from '@/mastodon/actions/modal';
import { changeSetting } from '@/mastodon/actions/settings';
import type { Status } from '@/mastodon/models/status';
import { useAppDispatch } from '@/mastodon/store';

import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  title: {
    id: 'confirmations.quiet_post_quote_info.title',
    defaultMessage: 'Quoting quiet public posts',
  },
  message: {
    id: 'confirmations.quiet_post_quote_info.message',
    defaultMessage:
      'When quoting a quiet public post, your post will be hidden from trending timelines.',
  },
  got_it: {
    id: 'confirmations.quiet_post_quote_info.got_it',
    defaultMessage: 'Got it',
  },
  dismiss: {
    id: 'confirmations.quiet_post_quote_info.dismiss',
    defaultMessage: "Don't remind me again",
  },
});

export const QuietPostQuoteInfoModal: React.FC<{ status: Status }> = ({
  status,
}) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const confirm = useCallback(() => {
    dispatch(quoteCompose(status));
    dispatch(
      closeModal({ modalType: 'CONFIRM_QUIET_QUOTE', ignoreFocus: true }),
    );
  }, [dispatch, status]);

  const dismiss = useCallback(() => {
    dispatch(quoteCompose(status));
    dispatch(
      changeSetting(['dismissed_banners', 'quote/quiet_post_hint'], true),
    );
    dispatch(
      closeModal({ modalType: 'CONFIRM_QUIET_QUOTE', ignoreFocus: true }),
    );
  }, [dispatch, status]);

  return (
    <ConfirmationModal
      closeWhenConfirm={false}
      title={intl.formatMessage(messages.title)}
      message={intl.formatMessage(messages.message)}
      confirm={intl.formatMessage(messages.got_it)}
      cancel={intl.formatMessage(messages.dismiss)}
      onConfirm={confirm}
      onClose={dismiss}
    />
  );
};
