import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { unblockAccount } from 'mastodon/actions/accounts';
import type { Account } from 'mastodon/models/account';
import { useAppDispatch } from 'mastodon/store';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  unblockConfirm: {
    id: 'confirmations.unblock.confirm',
    defaultMessage: 'Unblock',
  },
});

export const ConfirmUnblockModal: React.FC<
  {
    account: Account;
  } & BaseConfirmationModalProps
> = ({ account, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const onConfirm = useCallback(() => {
    dispatch(unblockAccount(account.id));
  }, [dispatch, account.id]);

  return (
    <ConfirmationModal
      title={
        <FormattedMessage
          id='confirmations.unblock.title'
          defaultMessage='Unblock {name}?'
          values={{ name: `@${account.acct}` }}
        />
      }
      confirm={intl.formatMessage(messages.unblockConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
