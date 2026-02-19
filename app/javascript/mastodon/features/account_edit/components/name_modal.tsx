import { useCallback, useId, useRef, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { TextInput } from '@/mastodon/components/form_fields';
import { insertEmojiAtPosition } from '@/mastodon/features/emoji/utils';
import type { BaseConfirmationModalProps } from '@/mastodon/features/ui/components/confirmation_modals';
import { ConfirmationModal } from '@/mastodon/features/ui/components/confirmation_modals';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';

import classes from '../styles.module.scss';

import { CharCounter } from './char_counter';
import { EmojiPicker } from './emoji_picker';

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
  const titleId = useId();
  const counterId = useId();
  const inputRef = useRef<HTMLInputElement>(null);
  const accountId = useCurrentAccountId();
  const account = useAccount(accountId);

  const [newName, setNewName] = useState(account?.display_name ?? '');
  const handleChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      setNewName(event.currentTarget.value);
    },
    [],
  );
  const handlePickEmoji = useCallback((emoji: string) => {
    setNewName((prev) => {
      const position = inputRef.current?.selectionStart ?? prev.length;
      return insertEmojiAtPosition(prev, emoji, position);
    });
  }, []);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.editTitle)}
      titleId={titleId}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={onClose} // To be implemented
      onClose={onClose}
      noCloseOnConfirm
      noFocusButton
    >
      <div className={classes.inputWrapper}>
        <TextInput
          value={newName}
          ref={inputRef}
          onChange={handleChange}
          className={classes.inputText}
          aria-labelledby={titleId}
          aria-describedby={counterId}
          // eslint-disable-next-line jsx-a11y/no-autofocus -- This is a modal, it's fine.
          autoFocus
        />
        <EmojiPicker onPick={handlePickEmoji} />
      </div>
      <CharCounter
        currentLength={newName.length}
        maxLength={MAX_NAME_LENGTH}
        id={counterId}
      />
    </ConfirmationModal>
  );
};
