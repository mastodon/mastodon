import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { useAccount } from 'mastodon/hooks/useAccount';

import type { BaseConfirmationModalProps } from './confirmation_modal';
import { ConfirmationModal } from './confirmation_modal';

const messages = defineMessages({
  title: {
    id: 'confirmations.follow_to_list.title',
    defaultMessage: 'Follow user?',
  },
  confirm: {
    id: 'confirmations.follow_to_list.confirm',
    defaultMessage: 'Follow and add to list',
  },
});

export const ConfirmFollowToListModal: React.FC<
  {
    accountId: string;
    onConfirm: () => void;
  } & BaseConfirmationModalProps
> = ({ accountId, onConfirm, onClose }) => {
  const intl = useIntl();
  const account = useAccount(accountId);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.title)}
      message={
        <FormattedMessage
          id='confirmations.follow_to_list.message'
          defaultMessage='You need to be following {name} to add them to a list.'
          values={{ name: <strong>@{account?.acct}</strong> }}
        />
      }
      confirm={intl.formatMessage(messages.confirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
