import { useCallback, useEffect, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { submitAccountNote } from '@/mastodon/actions/account_notes';
import { fetchRelationships } from '@/mastodon/actions/accounts';
import { TextAreaField } from '@/mastodon/components/form_fields';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { ConfirmationModal } from '../../ui/components/confirmation_modals';

import classes from './modals.module.css';

const messages = defineMessages({
  newTitle: {
    id: 'account_note_modal.title',
    defaultMessage: 'Add a personal note',
  },
  editTitle: {
    id: 'account_note_modal.edit_title',
    defaultMessage: 'Edit personal note',
  },
  save: {
    id: 'account_note_modal.save',
    defaultMessage: 'Save',
  },
  fieldLabel: {
    id: 'account_note_modal.field_label',
    defaultMessage: 'Personal Note',
  },
});

export const AccountNoteModal: FC<{
  accountId: string;
  onClose: () => void;
}> = ({ accountId, onClose }) => {
  const intl = useIntl();
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!relationship) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [accountId, dispatch, relationship]);

  const initialContents = relationship?.note ?? '';

  const [saving, setSaving] = useState(false);
  const [note, setNote] = useState(initialContents);
  const handleChange: ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (e) => {
      setNote(e.target.value);
    },
    [],
  );

  const handleSave = useCallback(() => {
    if (saving) {
      return;
    }
    setSaving(true);
    void dispatch(submitAccountNote({ accountId, note })).then(() => {
      setSaving(false);
    });
  }, [accountId, dispatch, note, saving]);

  return (
    <ConfirmationModal
      title={
        initialContents
          ? intl.formatMessage(messages.editTitle)
          : intl.formatMessage(messages.newTitle)
      }
      extraContent={
        <TextAreaField
          value={note}
          onChange={handleChange}
          label={intl.formatMessage(messages.fieldLabel)}
          className={classes.noteInput}
          // eslint-disable-next-line jsx-a11y/no-autofocus -- This is a modal, it's okay.
          autoFocus
        />
      }
      onClose={onClose}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
    />
  );
};
