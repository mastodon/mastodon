import { useCallback, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { TextInput } from '@/mastodon/components/form_fields';
import type { BaseConfirmationModalProps } from '@/mastodon/features/ui/components/confirmation_modals';
import { ConfirmationModal } from '@/mastodon/features/ui/components/confirmation_modals';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';

import classes from '../styles.module.scss';

import { CharCounter } from './char_counter';

const messages = defineMessages({
  addTitle: {
    id: 'account_edit.name_modal.add_title',
    defaultMessage: 'Add display name',
  },
  editTitle: {
    id: 'account_edit.name_modal.edit_title',
    defaultMessage: 'Edit display name',
  },
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
});

const MAX_NAME_LENGTH = 30;

export const NameModal: FC<BaseConfirmationModalProps> = ({ onClose }) => {
  const intl = useIntl();
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);

  const [newName, setNewName] = useState(account?.display_name ?? '');
  const handleChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      setNewName(event.currentTarget.value.slice(0, MAX_NAME_LENGTH));
    },
    [],
  );

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.editTitle)}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={onClose}
      onClose={onClose}
      noCloseOnConfirm
      noFocusButton
    >
      <TextInput
        value={newName}
        onChange={handleChange}
        maxLength={MAX_NAME_LENGTH}
        className={classes.inputText}
        // eslint-disable-next-line jsx-a11y/no-autofocus -- This is a modal, it's fine.
        autoFocus
      />
      <CharCounter currentLength={newName.length} maxLength={MAX_NAME_LENGTH} />
    </ConfirmationModal>
  );
};
