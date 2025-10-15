import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { unfollowAccount } from 'mastodon/actions/accounts';
import type { Account } from 'mastodon/models/account';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  withdrawConfirm: {
    id: 'confirmations.withdraw_request.confirm',
    defaultMessage: 'Withdraw request',
  },
});

export const ConfirmWithdrawRequestModal: React.FC<
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
      title={
        <FormattedMessage
          id='confirmations.withdraw_request.title'
          defaultMessage='Withdraw request to follow {name}?'
          values={{ name: `@${account.acct}` }}
        />
      }
      confirm={intl.formatMessage(messages.withdrawConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
