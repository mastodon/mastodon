import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import classNames from 'classnames';
import IconButton from 'mastodon/components/icon_button';
import Textarea from 'react-textarea-autosize';

const messages = defineMessages({
  edit_user_note: { id: 'account.edit_user_note', defaultMessage: 'Edit note for @{name}' },
  placeholder: { id: 'user_note.placeholder', defaultMessage: 'No comment provided' },
  save: { id: 'user_note.save', defaultMessage: 'Save' },
  cancel: { id: 'user_note.cancel', defaultMessage: 'Cancel' },
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
        <div>
          <IconButton
            icon='check'
            title={intl.formatMessage(messages.save)}
            onClick={this.props.onSaveUserNote}
            disabled={isSubmitting}
            size={15}
          />
          <IconButton
            icon='times'
            title={intl.formatMessage(messages.cancel)}
            onClick={this.props.onCancelUserNote}
            disabled={isSubmitting}
            size={15}
          />
        </div>
      );
    } else {
      action_buttons = (
        <div>
          <IconButton
            icon='pencil'
            title={intl.formatMessage(messages.edit_user_note, { name: account.get('username') })}
            onClick={this.props.onEditUserNote}
            disabled={isSubmitting}
            size={15}
          />
        </div>
      );
    }

    let note_container = null;
    if (isEditing) {
      note_container = (
        <Textarea
          disabled={isSubmitting}
          placeholder={intl.formatMessage(messages.placeholder)}
          autoFocus={true}
          value={userNote}
          onChange={this.handleChangeUserNote}
          onKeyDown={this.handleKeyDown}
        />
      );
    } else {
      note_container = (<div class='account__header__user-note__content'>{userNote}</div>);
    }

    return (
      <div className='account__header__user-note'>
        <div className='account__header__user-note__header'>
          <strong><FormattedMessage id='account.user_note_header' defaultMessage='Your note for @{name}' values={{ name: account.get('username') }} /></strong>
          {action_buttons}
        </div>
        {note_container}
      </div>
    );
  }

}
