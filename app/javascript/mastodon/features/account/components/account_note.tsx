import PropTypes from 'prop-types';
import type { ChangeEvent, KeyboardEvent } from 'react';
import { createRef, useEffect, useState } from 'react';

import type { IntlShape } from 'react-intl';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import Textarea from 'react-textarea-autosize';

import type { TypeSafeImmutableMap } from 'app/javascript/types/immutable';
import { submitAccountNote } from 'mastodon/actions/account_notes';
import type { Account } from 'mastodon/reducers/accounts';
import type { RootState } from 'mastodon/store';

const messages = defineMessages({
  placeholder: {
    id: 'account_note.placeholder',
    defaultMessage: 'Click to add a note',
  },
});

interface InlineAlertProps {
  show: boolean;
}

const InlineAlert = ({ show }: InlineAlertProps) => {
  const [mountMessage, setMountMessage] = useState(false);
  const TRANSITION_DELAY = 200;

  // TODO(trinitroglycerin): This effect changes the display of a message based on a flag, and hides it after a delay.
  // It occurs to me that this is probably best represented with CSS handling the transition between the two states, and not
  // handling this in JavaScript with the mountMessage state (which is the same value as 'show', but with a TRANSITION_DELAY lag).
  useEffect(() => {
    // Because show is a boolean value, this effect will only ever be triggered if it flips.
    // We therefore do not need to store the previous value because we know the previous value will
    // always be the opposite of the current value.
    if (show) {
      setMountMessage(true);
      return () => {
        // Intentionally left empty so the linter doesn't complain about having inconsistent returns
      };
    }

    const handle = setTimeout(() => {
      setMountMessage(false);
    }, TRANSITION_DELAY);

    return () => {
      clearTimeout(handle);
    };
  }, [show]);

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

InlineAlert.propTypes = {
  show: PropTypes.bool,
};

interface Props {
  accountId: string;
  value: string;
  onSave: (value: string) => void;
  intl: IntlShape;
}

interface State {
  value: string;
  saving: boolean;
  saved: boolean;
}

class AccountNote extends ImmutablePureComponent<Props, State> {
  state: State = {
    value: this.props.value,
    saving: false,
    saved: false,
  };

  textarea = createRef<HTMLTextAreaElement>();

  UNSAFE_componentWillReceiveProps(nextProps: Props) {
    const accountWillChange = this.props.accountId !== nextProps.accountId;

    // If the account will change and we've made some changes, make sure the changes are updated somewhere,
    // but ensure the change doesn't reflect.
    if (accountWillChange && this._isDirty()) {
      this._save(false);
    }

    if (accountWillChange || nextProps.value === this.state.value) {
      this.setState({ saving: false });
    }

    if (this.props.value !== nextProps.value) {
      this.setState({ value: nextProps.value });
    }
  }

  componentWillUnmount() {
    if (this._isDirty()) {
      this._save(false);
    }
  }

  handleChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
    this.setState({ value: e.target.value, saving: false });
  };

  handleKeyDown = (e: KeyboardEvent) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this._save();
      this.textarea.current?.blur();
    } else if (e.keyCode === 27) {
      e.preventDefault();
      this._reset(() => {
        this.textarea.current?.blur();
      });
    }
  };

  handleBlur = () => {
    if (this._isDirty()) {
      this._save();
    }
  };

  _save(showMessage = true) {
    this.setState({ saving: true });
    this.props.onSave(this.state.value);

    if (showMessage) {
      this.setState({ saved: true }, () =>
        setTimeout(() => this.setState({ saved: false }), 2000)
      );
    }
  }

  _reset(callback: () => void) {
    this.setState({ value: this.props.value }, callback);
  }

  _isDirty() {
    return (
      !this.state.saving &&
      this.props.value !== null &&
      this.state.value !== null &&
      this.state.value !== this.props.value
    );
  }

  render() {
    const { accountId, intl } = this.props;
    const { value, saved } = this.state;

    if (!accountId) {
      return null;
    }

    return (
      <div className='account__header__account-note'>
        <label htmlFor={`account-note-${accountId}`}>
          <FormattedMessage
            id='account.account_note_header'
            defaultMessage='Note'
          />{' '}
          <InlineAlert show={saved} />
        </label>

        <Textarea
          id={`account-note-${accountId}`}
          className='account__header__account-note__content'
          disabled={this.props.value === null || value === null}
          placeholder={intl.formatMessage(messages.placeholder)}
          value={value ?? ''}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyDown}
          onBlur={this.handleBlur}
          ref={this.textarea}
        />
      </div>
    );
  }
}

const mapStateToProps = (
  state: RootState,
  { account }: { account: TypeSafeImmutableMap<Account> }
) => ({
  accountId: account.get('id'),
  value: account.getIn(['relationship', 'note']) as string,
});

const mapDispatchToProps = (
  // TODO: This type is wrong.
  dispatch: (action: any) => void,
  { account }: { account: TypeSafeImmutableMap<Account> }
) => ({
  onSave(value: string) {
    dispatch(submitAccountNote(account.get('id'), value));
  },
});

const connected = injectIntl(
  connect(mapStateToProps, mapDispatchToProps)(AccountNote)
);

// TODO(trinitroglycerin): Probably should rename this back to AccountNoteContainer and AccountNote
export { connected as AccountNote, AccountNote as __AccountNote };
