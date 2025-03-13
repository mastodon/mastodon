import PropTypes from 'prop-types';
import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import Textarea from 'react-textarea-autosize';

import { submitAccountNote } from 'mastodon/actions/account_notes';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

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
  const initialValue = useAppSelector(state => state.relationships.get(accountId)?.get('note'));
  const [value, setValue] = useState(initialValue);
  const [saved, setSaved] = useState(false);

  // We need to access the value on unmount
  const valueRef = useRef(value);
  const dirtyRef = useRef(false);

  // Keep the valueRef in sync with the state
  useEffect(() => {
    valueRef.current = value;
  }, [value]);

  useEffect(() => {
    if (initialValue !== valueRef.current) setValue(initialValue);
  }, [initialValue, setValue]);

  useEffect(() => {
    dirtyRef.current = initialValue !== value;
  }, [initialValue, value]);

  const onSave = useCallback((value) => {
    dispatch(submitAccountNote({ accountId, note: value }));

    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  }, [accountId, dispatch, setSaved]);

  // Save changes on unmount
  useEffect(() => {
    return () => {
      if (dirtyRef.current) onSave(valueRef.current);
    };
  }, [onSave]);

  const handleChange = useCallback((e) => {
    setValue(e.target.value);
  }, [setValue]);

  const handleKeyDown = useCallback((e) => {
    if (e.keyCode === 27) {
      e.preventDefault();

      setValue(initialValue);
      e.target.blur();
    } else if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();

      onSave(valueRef.current);

      e.target.blur();
    }
  }, [onSave, initialValue]);

  const handleBlur = useCallback(() => {
    if (dirtyRef.current) onSave(valueRef.current);
  }, [onSave]);

  return (
    <div className='account__header__account-note'>
      <label htmlFor={`account-note-${accountId}`}>
        <FormattedMessage id='account.account_note_header' defaultMessage='Personal note' /> <InlineAlert show={saved} />
      </label>

      <Textarea
        id={`account-note-${accountId}`}
        className='account__header__account-note__content'
        disabled={initialValue === null || value === null}
        placeholder={intl.formatMessage(messages.placeholder)}
        value={value || ''}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        onBlur={handleBlur}
      />
    </div>
  );
};

InnerAccountNote.propTypes = {
  accountId: PropTypes.string,
};

const AccountNote = ({ accountId }) => (<InnerAccountNote accountId={accountId} key={`account-note-{accountId}`} />);

AccountNote.propTypes = {
  accountId: PropTypes.string,
};

export default AccountNote;
