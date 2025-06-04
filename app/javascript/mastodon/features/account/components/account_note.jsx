import PropTypes from 'prop-types';
import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import Textarea from 'react-textarea-autosize';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { submitAccountNote } from '@/mastodon/actions/account_notes';

import { LoadingIndicator } from '@/mastodon/components/loading_indicator';

const messages = defineMessages({
  placeholder: { id: 'account_note.placeholder', defaultMessage: 'Click to add a note' },
});

const InlineAlert = ({ show }) => {
  const [mountMessage, setMountMessage] = useState(false);

  useEffect(() => {
    if (show) {
      setMountMessage(true);
    } else {
      setTimeout(() => setMountMessage(false), 200);
    }
  }, [show, setMountMessage]);

  return (
    <span aria-live='polite' role='status' className='inline-alert' style={{ opacity: show ? 1 : 0 }}>
      {mountMessage && <FormattedMessage id='generic.saved' defaultMessage='Saved' />}
    </span>
  );
};

InlineAlert.propTypes = {
  show: PropTypes.bool,
};

const InnerAccountNote = ({ accountId }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const initialValue = useAppSelector((state) =>
    state.relationships.get(accountId)?.get('note') ?? ''
  );
  const [value, setValue] = useState(initialValue);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const valueRef = useRef(value);

  const onSave = useCallback(
    () => {
      setSaving(true);

      dispatch(submitAccountNote({ accountId, note: valueRef.current }));

      setSaved(true);
      setTimeout(() => {
        setSaving(false);
        setSaved(false);
      }, 2000);
    },
    [accountId, setSaved, setSaving, dispatch],
  );

  const handleChange = useCallback(
    (e) => {
      setValue(e.target.value);
      valueRef.current = e.target.value;
    },
    [setValue],
  );

  const handleKeyDown = useCallback(
    (e) => {
      if (e.key === 'Escape') {
        e.preventDefault();

        setValue(initialValue);
        valueRef.current = initialValue;

        e.currentTarget.blur();
      } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();

        onSave();

        e.currentTarget.blur();
      }
    },
    [initialValue, setValue, onSave],
  );

  const handleBlur = useCallback(
    (e) => {
      if (initialValue !== valueRef.current && !saved && !saving) {
        onSave();
      }
    },
    [onSave, saving, saved, initialValue]
  );

  useEffect(() => {
    if (initialValue !== valueRef.current) {
      setValue(initialValue);
      valueRef.current = initialValue;
    }

    return () => {
      if (initialValue !== valueRef.current) {
        onSave(valueRef.current);
      }
    }
  }, [initialValue, setValue, onSave]);

  return (
    <div className='account__header__account-note'>
      <label htmlFor={`account-note-${accountId}`}>
        <FormattedMessage
          id='account.account_note_header'
          defaultMessage='Personal note'
        />{' '}
        <InlineAlert show={saved} />
      </label>
      {value === undefined ? (
        <div className='account__header__account-note__loading-indicator-wrapper'>
          <LoadingIndicator />
        </div>
      ) : (
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
      )}
    </div>
  );
};

InnerAccountNote.propTypes = {
  accountId: PropTypes.string.isRequired,
}

export const AccountNote = ({ accountId }) => (
  <InnerAccountNote accountId={accountId} key={`account-note-${accountId}`} />
);

AccountNote.propTypes = {
  accountId: PropTypes.string.isRequired,
}

