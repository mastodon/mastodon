import { useCallback, useId, useRef, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { TextArea } from '@/mastodon/components/form_fields';
import { insertEmojiAtPosition } from '@/mastodon/features/emoji/utils';
import type { BaseConfirmationModalProps } from '@/mastodon/features/ui/components/confirmation_modals';
import { ConfirmationModal } from '@/mastodon/features/ui/components/confirmation_modals';
import { patchProfile } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from '../styles.module.scss';

import { CharCounter } from './char_counter';
import { EmojiPicker } from './emoji_picker';

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
  const titleId = useId();
  const counterId = useId();
  const textAreaRef = useRef<HTMLTextAreaElement>(null);

  const { profile: { bio } = {}, isPending } = useAppSelector(
    (state) => state.profileEdit,
  );
  const [newBio, setNewBio] = useState(bio ?? '');
  const handleChange: ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      setNewBio(event.currentTarget.value);
    },
    [],
  );
  const handlePickEmoji = useCallback((emoji: string) => {
    setNewBio((prev) => {
      const position = textAreaRef.current?.selectionStart ?? prev.length;
      return insertEmojiAtPosition(prev, emoji, position);
    });
  }, []);

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    if (!isPending) {
      void dispatch(patchProfile({ note: newBio })).then(onClose);
    }
  }, [dispatch, isPending, newBio, onClose]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(bio ? messages.editTitle : messages.addTitle)}
      titleId={titleId}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
      onClose={onClose}
      updating={isPending}
      disabled={newBio.length > MAX_BIO_LENGTH}
      noFocusButton
    >
      <div className={classes.inputWrapper}>
        <TextArea
          value={newBio}
          ref={textAreaRef}
          onChange={handleChange}
          className={classes.inputText}
          aria-labelledby={titleId}
          aria-describedby={counterId}
          // eslint-disable-next-line jsx-a11y/no-autofocus -- This is a modal, it's fine.
          autoFocus
          autoSize
        />
        <EmojiPicker onPick={handlePickEmoji} />
      </div>
      <CharCounter
        currentLength={newBio.length}
        maxLength={MAX_BIO_LENGTH}
        id={counterId}
      />
    </ConfirmationModal>
  );
};
