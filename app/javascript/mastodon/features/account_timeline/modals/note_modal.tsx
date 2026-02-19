import { useCallback, useEffect, useRef, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { submitAccountNote } from '@/mastodon/actions/account_notes';
import { fetchRelationships } from '@/mastodon/actions/accounts';
import { Callout } from '@/mastodon/components/callout';
import { TextAreaField } from '@/mastodon/components/form_fields';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import type { Relationship } from '@/mastodon/models/relationship';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { ConfirmationModal } from '../../ui/components/confirmation_modals';

import classes from './modals.module.css';

const messages = defineMessages({
  newTitle: {
    id: 'account.node_modal.title',
    defaultMessage: 'Add a personal note',
  },
  editTitle: {
    id: 'account.node_modal.edit_title',
    defaultMessage: 'Edit personal note',
  },
  save: {
    id: 'account.node_modal.save',
    defaultMessage: 'Save',
  },
  fieldLabel: {
    id: 'account.node_modal.field_label',
    defaultMessage: 'Personal Note',
  },
  errorUnknown: {
    id: 'account.node_modal.error_unknown',
    defaultMessage: 'Could not save the note',
  },
});

export const AccountNoteModal: FC<{
  accountId: string;
  onClose: () => void;
}> = ({ accountId, onClose }) => {
  const relationship = useAppSelector((state) =>
    state.relationships.get(accountId),
  );
  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!relationship) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [accountId, dispatch, relationship]);

  if (!relationship) {
    return <LoadingIndicator />;
  }

  return (
    <InnerNodeModal
      relationship={relationship}
      accountId={accountId}
      onClose={onClose}
    />
  );
};

const InnerNodeModal: FC<{
  relationship: Relationship;
  accountId: string;
  onClose: () => void;
}> = ({ relationship, accountId, onClose }) => {
  // Set up the state.
  const initialContents = relationship.note;
  const [note, setNote] = useState(initialContents);
  const [errorText, setErrorText] = useState('');
  const [state, setState] = useState<'idle' | 'saving' | 'error'>('idle');
  const isDirty = note !== initialContents;

  const handleChange: ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (e) => {
      if (state !== 'saving') {
        setNote(e.target.value);
      }
    },
    [state],
  );

  const intl = useIntl();

  // Create an abort controller to cancel the request if the modal is closed.
  const abortController = useRef(new AbortController());
  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    if (state === 'saving' || !isDirty) {
      return;
    }
    setState('saving');
    dispatch(
      submitAccountNote(
        { accountId, note },
        { signal: abortController.current.signal },
      ),
    )
      .then(() => {
        setState('idle');
        onClose();
      })
      .catch((err: unknown) => {
        setState('error');
        if (err instanceof Error) {
          setErrorText(err.message);
        } else {
          setErrorText(intl.formatMessage(messages.errorUnknown));
        }
      });
  }, [accountId, dispatch, intl, isDirty, note, onClose, state]);

  const handleCancel = useCallback(() => {
    abortController.current.abort();
    onClose();
  }, [onClose]);

  return (
    <ConfirmationModal
      title={
        initialContents
          ? intl.formatMessage(messages.editTitle)
          : intl.formatMessage(messages.newTitle)
      }
      extraContent={
        <>
          <Callout className={classes.noteCallout}>
            <FormattedMessage
              id='account.node_modal.callout'
              defaultMessage='Personal notes are visible only to you.'
            />
          </Callout>
          <TextAreaField
            value={note}
            onChange={handleChange}
            label={intl.formatMessage(messages.fieldLabel)}
            className={classes.noteInput}
            hasError={state === 'error'}
            hint={errorText}
            // eslint-disable-next-line jsx-a11y/no-autofocus -- We want to focus here as it's a modal.
            autoFocus
          />
        </>
      }
      onClose={handleCancel}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
      updating={state === 'saving'}
      disabled={!isDirty}
      noCloseOnConfirm
      noFocusButton
    />
  );
};
