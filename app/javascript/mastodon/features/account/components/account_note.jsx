import PropTypes from 'prop-types';
import { createRef, useEffect, useState } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { is } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import Textarea from 'react-textarea-autosize';

const messages = defineMessages({
  placeholder: { id: 'account_note.placeholder', defaultMessage: 'Click to add a note' },
});


const InlineAlert = ({ show }) => {
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
      // A bare function is returned here so we can return a cleanup function later.
      return () => { };
    }

    const handle = setTimeout(() => {
      setMountMessage(false);
    }, TRANSITION_DELAY);

    return () => {
      clearTimeout(handle);
    };
  }, [show]);

  return (
    <span aria-live='polite' role='status' className='inline-alert' style={{ opacity: show ? 1 : 0 }}>
      {mountMessage && <FormattedMessage id='generic.saved' defaultMessage='Saved' />}
    </span>
  );
};

InlineAlert.propTypes = {
  show: PropTypes.bool,
};

class AccountNote extends ImmutablePureComponent {
  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    value: PropTypes.string,
    onSave: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    value: null,
    saving: false,
    saved: false,
  };

  textarea = createRef();

  UNSAFE_componentWillMount() {
    this._reset();
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    const accountWillChange = !is(this.props.account, nextProps.account);
    const newState = {};

    if (accountWillChange && this._isDirty()) {
      this._save(false);
    }

    if (accountWillChange || nextProps.value === this.state.value) {
      newState.saving = false;
    }

    if (this.props.value !== nextProps.value) {
      newState.value = nextProps.value;
    }

    this.setState(newState);
  }

  componentWillUnmount() {
    if (this._isDirty()) {
      this._save(false);
    }
  }

  handleChange = e => {
    this.setState({ value: e.target.value, saving: false });
  };

  handleKeyDown = e => {
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
    this.setState({ saving: true }, () => this.props.onSave(this.state.value));

    if (showMessage) {
      this.setState({ saved: true }, () => setTimeout(() => this.setState({ saved: false }), 2000));
    }
  }

  _reset(callback) {
    this.setState({ value: this.props.value }, callback);
  }

  _isDirty() {
    return !this.state.saving && this.props.value !== null && this.state.value !== null && this.state.value !== this.props.value;
  }

  render() {
    const { account, intl } = this.props;
    const { value, saved } = this.state;

    if (!account) {
      return null;
    }

    return (
      <div className='account__header__account-note'>
        <label htmlFor={`account-note-${account.get('id')}`}>
          <FormattedMessage id='account.account_note_header' defaultMessage='Note' /> <InlineAlert show={saved} />
        </label>

        <Textarea
          id={`account-note-${account.get('id')}`}
          className='account__header__account-note__content'
          disabled={this.props.value === null || value === null}
          placeholder={intl.formatMessage(messages.placeholder)}
          value={value || ''}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyDown}
          onBlur={this.handleBlur}
          ref={this.textarea}
        />
      </div>
    );
  }

}

export default injectIntl(AccountNote);
