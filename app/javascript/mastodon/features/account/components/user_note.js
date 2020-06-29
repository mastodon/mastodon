import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Icon from 'mastodon/components/icon';
import Textarea from 'react-textarea-autosize';

const messages = defineMessages({
  placeholder: { id: 'user_note.placeholder', defaultMessage: 'No comment provided' },
});

export default @injectIntl
class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    isEditing: PropTypes.bool,
    isSubmitting: PropTypes.bool,
    userNote: PropTypes.string,
    onEditUserNote: PropTypes.func.isRequired,
    onCancelUserNote: PropTypes.func.isRequired,
    onSaveUserNote: PropTypes.func.isRequired,
    onChangeUserNote: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleChangeUserNote = (e) => {
    this.props.onChangeUserNote(e.target.value);
  };

  componentWillUnmount () {
    if (this.props.isEditing) {
      this.props.onCancelUserNote();
    }
  }

  handleKeyDown = e => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.props.onSaveUserNote();
    } else if (e.keyCode === 27) {
      this.props.onCancelUserNote();
    }
  }

  render () {
    const { account, userNote, isEditing, isSubmitting, intl } = this.props;

    if (!account || (!userNote && !isEditing)) {
      return null;
    }

    let action_buttons = null;
    if (isEditing) {
      action_buttons = (
        <div className='account__header__user-note__buttons'>
          <button className='text-btn' tabIndex='0' onClick={this.props.onCancelUserNote} disabled={isSubmitting}>
            <Icon id='times' size={15} /> <FormattedMessage id='user_note.cancel' defaultMessage='Cancel' />
          </button>
          <button className='text-btn' tabIndex='0' onClick={this.props.onSaveUserNote} disabled={isSubmitting}>
            <Icon id='check' size={15} /> <FormattedMessage id='user_note.save' defaultMessage='Save' />
          </button>
        </div>
      );
    }

    let note_container = null;
    if (isEditing) {
      note_container = (
        <Textarea
          className='account__header__user-note__content'
          disabled={isSubmitting}
          placeholder={intl.formatMessage(messages.placeholder)}
          value={userNote}
          onChange={this.handleChangeUserNote}
          onKeyDown={this.handleKeyDown}
          autoFocus
        />
      );
    } else {
      note_container = (<div className='account__header__user-note__content'>{userNote}</div>);
    }

    return (
      <div className='account__header__user-note'>
        <div className='account__header__user-note__header'>
          <strong><FormattedMessage id='account.user_note_header' defaultMessage='Your note for @{name}' values={{ name: account.get('username') }} /></strong>
          {!isEditing && (
            <div>
              <button className='text-btn' tabIndex='0' onClick={this.props.onEditUserNote} disabled={isSubmitting}>
                <Icon id='pencil' size={15} /> <FormattedMessage id='user_note.edit' defaultMessage='Edit' />
              </button>
            </div>
          )}
        </div>
        {note_container}
        {action_buttons}
      </div>
    );
  }

}
