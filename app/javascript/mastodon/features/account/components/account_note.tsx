import type { ChangeEventHandler, KeyboardEventHandler } from 'react';
import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import Textarea from 'react-textarea-autosize';

import { submitAccountNote } from 'mastodon/actions/account_notes';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  placeholder: {
    id: 'account_note.placeholder',
    defaultMessage: 'Click to add a note',
  },
});

const InlineAlert: React.FC<{ show: boolean }> = ({ show }) => {
  const [mountMessage, setMountMessage] = useState(false);

  useEffect(() => {
    if (show) {
      setMountMessage(true);
    } else {
      setTimeout(() => {
        setMountMessage(false);
      }, 200);
    }
  }, [show, setMountMessage]);

  return (
    <span
      aria-live='polite'
      role='status'
      className='inline-alert'
      style={{ opacity: show ? 1 : 0 }}
    >
      {mountMessage && (
        <FormattedMessage id='generic.saved' defaultMessage='Saved' />
      )}
    </span>
  );
};

interface Props {
  accountId: string;
}

const InnerAccountNote: React.FC<Props> = ({ accountId }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const initialValue = useAppSelector((state) =>
    state.relationships.get(accountId)?.get('note'),
  );
  const [value, setValue] = useState<string>(initialValue ?? '');
  const [saved, setSaved] = useState(false);

  const dirtyRef = useRef(false);

  useEffect(() => {
    dirtyRef.current = initialValue !== undefined && initialValue !== value;
  }, [initialValue, value]);

  const onSave = useCallback(
    (value: string) => {
      void dispatch(submitAccountNote({ accountId, note: value }));

      setSaved(true);
      setTimeout(() => {
        setSaved(false);
      }, 2000);
    },
    [accountId, dispatch, setSaved],
  );

  const handleChange = useCallback<ChangeEventHandler<HTMLTextAreaElement>>(
    (e) => {
      setValue(e.target.value);
    },
    [setValue],
  );

  const handleKeyDown = useCallback<KeyboardEventHandler<HTMLTextAreaElement>>(
    (e) => {
      if (e.key === 'Escape') {
        e.preventDefault();

        setValue(initialValue ?? '');
        e.currentTarget.blur();
      } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();

        onSave(value);

        e.currentTarget.blur();
      }
    },
    [onSave, initialValue, value, setValue],
  );

  const handleBlur = useCallback(() => {
    if (dirtyRef.current) onSave(value);
  }, [onSave, value]);

  // To save the changes on unmount, we need to synchronize the state in a ref
  const valueRef = useRef<string>(value);

  useEffect(() => {
    valueRef.current = value;
  }, [value]);

  useEffect(() => {
    return () => {
      if (dirtyRef.current) onSave(valueRef.current);
    };
  }, [onSave]);

  // Handle `initialValue` changes
  useEffect(() => {
    if (initialValue !== valueRef.current) setValue(initialValue ?? '');
  }, [initialValue, setValue]);

  return (
    <div className='account__header__account-note'>
      <label htmlFor={`account-note-${accountId}`}>
        <FormattedMessage
          id='account.account_note_header'
          defaultMessage='Personal note'
        />{' '}
        <InlineAlert show={saved} />
      </label>

      <Textarea
        id={`account-note-${accountId}`}
        className='account__header__account-note__content'
        disabled={initialValue === undefined}
        placeholder={intl.formatMessage(messages.placeholder)}
        value={value || ''}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        onBlur={handleBlur}
      />
    </div>
  );
};

export const AccountNote: React.FC<Props> = ({ accountId }) => (
  <InnerAccountNote accountId={accountId} key={`account-note-{accountId}`} />
);
