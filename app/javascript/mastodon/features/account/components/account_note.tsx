import type { ChangeEventHandler, KeyboardEventHandler } from 'react';
import { useState, useRef, useCallback, useId } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import Textarea from 'react-textarea-autosize';

import { submitAccountNote } from '@/mastodon/actions/account_notes';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const messages = defineMessages({
  placeholder: {
    id: 'account_note.placeholder',
    defaultMessage: 'Click to add a note',
  },
});

const AccountNoteUI: React.FC<{
  initialValue: string | undefined;
  onSubmit: (newNote: string) => void;
  wasSaved: boolean;
}> = ({ initialValue, onSubmit, wasSaved }) => {
  const intl = useIntl();
  const uniqueId = useId();
  const [value, setValue] = useState(initialValue ?? '');
  const isLoading = initialValue === undefined;
  const canSubmitOnBlurRef = useRef(true);

  const handleChange = useCallback<ChangeEventHandler<HTMLTextAreaElement>>(
    (e) => {
      setValue(e.target.value);
    },
    [],
  );

  const handleKeyDown = useCallback<KeyboardEventHandler<HTMLTextAreaElement>>(
    (e) => {
      if (e.key === 'Escape') {
        e.preventDefault();

        setValue(initialValue ?? '');

        canSubmitOnBlurRef.current = false;
        e.currentTarget.blur();
      } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();

        onSubmit(value);

        canSubmitOnBlurRef.current = false;
        e.currentTarget.blur();
      }
    },
    [initialValue, onSubmit, value],
  );

  const handleBlur = useCallback(() => {
    if (initialValue !== value && canSubmitOnBlurRef.current) {
      onSubmit(value);
    }
    canSubmitOnBlurRef.current = true;
  }, [initialValue, onSubmit, value]);

  return (
    <div className='account__header__account-note'>
      <label htmlFor={`account-note-${uniqueId}`}>
        <FormattedMessage
          id='account.account_note_header'
          defaultMessage='Personal note'
        />{' '}
        <span
          aria-live='polite'
          role='status'
          className='inline-alert'
          style={{ opacity: wasSaved ? 1 : 0 }}
        >
          {wasSaved && (
            <FormattedMessage id='generic.saved' defaultMessage='Saved' />
          )}
        </span>
      </label>
      {isLoading ? (
        <div className='account__header__account-note__loading-indicator-wrapper'>
          <LoadingIndicator />
        </div>
      ) : (
        <Textarea
          id={`account-note-${uniqueId}`}
          className='account__header__account-note__content'
          placeholder={intl.formatMessage(messages.placeholder)}
          value={value}
          onChange={handleChange}
          onKeyDown={handleKeyDown}
          onBlur={handleBlur}
        />
      )}
    </div>
  );
};

export const AccountNote: React.FC<{
  accountId: string;
}> = ({ accountId }) => {
  const dispatch = useAppDispatch();
  const initialValue = useAppSelector((state) =>
    state.relationships.get(accountId)?.get('note'),
  );
  const [wasSaved, setWasSaved] = useState(false);

  const handleSubmit = useCallback(
    (note: string) => {
      setWasSaved(true);
      void dispatch(submitAccountNote({ accountId, note }));

      setTimeout(() => {
        setWasSaved(false);
      }, 2000);
    },
    [dispatch, accountId],
  );

  return (
    <AccountNoteUI
      key={`${accountId}-${initialValue}`}
      initialValue={initialValue}
      wasSaved={wasSaved}
      onSubmit={handleSubmit}
    />
  );
};
