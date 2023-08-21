import PropTypes from 'prop-types';
import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import Textarea from 'react-textarea-autosize';

import { InlineAlert } from './inline-alert';

const messages = defineMessages({
  placeholder: { id: 'account_note.placeholder', defaultMessage: 'Click to add a note' },
});

export const AccountNote = ({ accountId, value: propsValue, onSave }) => {
  const intl = useIntl();
  const [value, setValue] = useState(propsValue);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const textarea = useRef(null);
  const prevAccountId = useRef(accountId);

  const isDirty = !saving && value !== propsValue;
  const _save = useCallback(
    (showMessage = false) => {
      // If our form is not dirty, we do not save changes.
      if (!isDirty) {
        return;
      }

      setSaving(true);
      onSave(value);

      if (showMessage) {
        setSaved(true);
        setTimeout(() => setSaved(false), 2000);
      }
    },
    [value, onSave, isDirty]
  );

  const prevPropsValue = useRef(propsValue);
  useEffect(() => {
    if (propsValue === value) {
      // If there was no change, we're no longer saving.
      setSaving(false);
    }

    if (prevPropsValue.current !== propsValue) {
      // Update the value from props if it changed
      setValue(propsValue);
      prevPropsValue.current = propsValue;
    }
  }, [propsValue, value]);

  useEffect(() => {
    const accountWillChange = prevAccountId.current !== accountId;
    // If the account will change and we've made some changes, make sure the changes are updated somewhere,
    // but ensure the change doesn't reflect.
    if (accountWillChange) {
      _save();
      setSaving(false);
    }

    prevAccountId.current = accountId;
  }, [accountId, _save]);

  useOnUnmount(_save);

  const handleChange = useCallback((e) => {
    setValue(e.target.value);
    setSaving(false);
  }, []);

  const handleKeyDown = useCallback(
    (e) => {
      if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        _save(true);
        textarea.current?.blur();
      } else if (e.keyCode === 27) {
        e.preventDefault();
        // Reset the value to the original one before we made changes.
        setValue(propsValue);
        textarea.current?.blur();
      }
    },
    [_save, propsValue]
  );

  const handleBlur = useCallback(() => _save(false), [_save]);

  if (accountId === null) {
    return null;
  }

  return (
    <div className='account__header__account-note'>
      <label htmlFor={`account-note-${accountId}`}>
        <FormattedMessage
          id='account.account_note_header'
          defaultMessage='Note'
        />{' '}
        <InlineAlert show={saved}>
          <FormattedMessage id='generic.saved' defaultMessage='Saved' />
        </InlineAlert>
      </label>

      <Textarea
        id={`account-note-${accountId}`}
        className='account__header__account-note__content'
        disabled={propsValue === null || value === null}
        placeholder={intl.formatMessage(messages.placeholder)}
        value={value}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        onBlur={handleBlur}
        ref={textarea}
      />
    </div>
  );
};

AccountNote.propTypes = {
  accountId: PropTypes.string.isRequired,
  value: PropTypes.string,
  onSave: PropTypes.func.isRequired
};

const useOnUnmount = (callback) => {
  const isUnmounting = useRef(false);
  useEffect(() => {
    return () => {
      isUnmounting.current = true;
    };
  }, []);

  useEffect(() => {
    return () => {
      if (isUnmounting.current) {
        callback();
      }
    };
  }, [callback]);
}
