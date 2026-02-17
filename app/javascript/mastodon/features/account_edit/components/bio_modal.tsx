import { useCallback, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { TextArea } from '@/mastodon/components/form_fields';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import type { BaseConfirmationModalProps } from '@/mastodon/features/ui/components/confirmation_modals';
import { ConfirmationModal } from '@/mastodon/features/ui/components/confirmation_modals';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useAppDispatch } from '@/mastodon/store';

const messages = defineMessages({
  addTitle: {
    id: 'account_edit.bio_modal.add_title',
    defaultMessage: 'Add bio',
  },
  editTitle: {
    id: 'account_edit.bio_modal.edit_title',
    defaultMessage: 'Edit bio',
  },
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
});

const MAX_BIO_LENGTH = 500;

export const BioModal: FC<BaseConfirmationModalProps> = ({ onClose }) => {
  const intl = useIntl();
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);

  const [newBio, setNewBio] = useState(account?.note_plain ?? '');
  const handleChange: ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      setNewBio(event.currentTarget.value.slice(0, MAX_BIO_LENGTH));
    },
    [],
  );

  const dispatch = useAppDispatch();
  const handleConfirm = useCallback(() => {
    dispatch(() => 'foo');
  }, [dispatch]);

  if (!account) {
    return <LoadingIndicator />;
  }

  return (
    <ConfirmationModal
      title={intl.formatMessage(
        account.note_plain ? messages.editTitle : messages.addTitle,
      )}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleConfirm}
      onClose={onClose}
      noFocusButton
    >
      <TextArea value={newBio} onChange={handleChange} />
      <p>
        {newBio.length}/{MAX_BIO_LENGTH} characters
      </p>
    </ConfirmationModal>
  );
};
