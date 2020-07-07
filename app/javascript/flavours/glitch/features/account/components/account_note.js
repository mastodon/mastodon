import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Icon from 'flavours/glitch/components/icon';
import Textarea from 'react-textarea-autosize';

const messages = defineMessages({
  placeholder: { id: 'account_note.glitch_placeholder', defaultMessage: 'No comment provided' },
});

export default @injectIntl
class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    isEditing: PropTypes.bool,
    isSubmitting: PropTypes.bool,
    accountNote: PropTypes.string,
    onEditAccountNote: PropTypes.func.isRequired,
    onCancelAccountNote: PropTypes.func.isRequired,
    onSaveAccountNote: PropTypes.func.isRequired,
    onChangeAccountNote: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleChangeAccountNote = (e) => {
    this.props.onChangeAccountNote(e.target.value);
  };

  componentWillUnmount () {
    if (this.props.isEditing) {
      this.props.onCancelAccountNote();
    }
  }

  handleKeyDown = e => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.props.onSaveAccountNote();
    } else if (e.keyCode === 27) {
      this.props.onCancelAccountNote();
    }
  }

  render () {
    const { account, accountNote, isEditing, isSubmitting, intl } = this.props;

    if (!account || (!accountNote && !isEditing)) {
      return null;
    }

    let action_buttons = null;
    if (isEditing) {
      action_buttons = (
        <div className='account__header__account-note__buttons'>
          <button className='text-btn' tabIndex='0' onClick={this.props.onCancelAccountNote} disabled={isSubmitting}>
            <Icon id='times' size={15} /> <FormattedMessage id='account_note.cancel' defaultMessage='Cancel' />
          </button>
          <div className='flex-spacer' />
          <button className='text-btn' tabIndex='0' onClick={this.props.onSaveAccountNote} disabled={isSubmitting}>
            <Icon id='check' size={15} /> <FormattedMessage id='account_note.save' defaultMessage='Save' />
          </button>
        </div>
      );
    } else {
      action_buttons = (
        <div className='account__header__account-note__buttons'>
          <button className='text-btn' tabIndex='0' onClick={this.props.onEditAccountNote} disabled={isSubmitting}>
            <Icon id='pencil' size={15} /> <FormattedMessage id='account_note.edit' defaultMessage='Edit' />
          </button>
        </div>
      );
    }

    let note_container = null;
    if (isEditing) {
      note_container = (
        <Textarea
          className='account__header__account-note__content'
          disabled={isSubmitting}
          placeholder={intl.formatMessage(messages.placeholder)}
          value={accountNote}
          onChange={this.handleChangeAccountNote}
          onKeyDown={this.handleKeyDown}
          autoFocus
        />
      );
    } else {
      note_container = (<div className='account__header__account-note__content'>{accountNote}</div>);
    }

    return (
      <div className='account__header__account-note'>
        <div className='account__header__account-note__header'>
          <strong><FormattedMessage id='account.account_note_header' defaultMessage='Note' /></strong>
          {action_buttons}
        </div>
        {note_container}
      </div>
    );
  }

}
