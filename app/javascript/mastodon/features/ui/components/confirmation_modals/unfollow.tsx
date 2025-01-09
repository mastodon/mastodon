import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { unfollowAccount } from 'mastodon/actions/accounts';
import type { Account } from 'mastodon/models/account';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  unfollowTitle: {
    id: 'confirmations.unfollow.title',
    defaultMessage: 'Unfollow user?',
  },
  unfollowConfirm: {
    id: 'confirmations.unfollow.confirm',
    defaultMessage: 'Unfollow',
  },
});

export const ConfirmUnfollowModal: React.FC<
  {
    account: Account;
  } & BaseConfirmationModalProps
> = ({ account, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const onConfirm = useCallback(() => {
    dispatch(unfollowAccount(account.id));
  }, [dispatch, account.id]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.unfollowTitle)}
      message={
        <FormattedMessage
          id='confirmations.unfollow.message'
          defaultMessage='Are you sure you want to unfollow {name}?'
          values={{ name: <strong>@{account.acct}</strong> }}
        />
      }
      confirm={intl.formatMessage(messages.unfollowConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
