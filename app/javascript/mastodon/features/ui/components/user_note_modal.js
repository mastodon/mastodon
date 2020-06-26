import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { makeGetAccount } from '../../../selectors';
import Button from '../../../components/button';
import { closeModal } from '../../../actions/modal';
import { changeUserNoteComment, submitUserNote } from '../../../actions/user_notes';
import IconButton from 'mastodon/components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  placeholder: { id: 'user_note.placeholder', defaultMessage: 'No comment provided' },
  save: { id: 'user_note.save', defaultMessage: 'Save' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = state => ({
    isSubmitting: state.getIn(['user_notes', 'edit', 'isSubmitting']),
    account: getAccount(state, state.getIn(['user_notes', 'edit', 'account_id'])),
    comment: state.getIn(['user_notes', 'edit', 'comment']),
  });

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => {
  return {
    onConfirm() {
      dispatch(submitUserNote());
    },

    onClose() {
      dispatch(closeModal());
    },

    onCommentChange(comment) {
      dispatch(changeUserNoteComment(comment));
    },
  };
};

export default @connect(makeMapStateToProps, mapDispatchToProps)
@injectIntl
class UserNoteModal extends React.PureComponent {

  static propTypes = {
    isSubmitting: PropTypes.bool,
    account: PropTypes.object.isRequired,
    onClose: PropTypes.func.isRequired,
    onConfirm: PropTypes.func.isRequired,
    onCommentChange: PropTypes.func.isRequired,
    comment: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  handleCommentChange = e => {
    this.props.onCommentChange(e.target.value);
  }

  handleSubmit = () => {
    this.props.onConfirm();
  }

  handleKeyDown = e => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleSubmit();
    }
  }


  render () {
    const { account, isSubmitting, comment, onClose, intl } = this.props;

    return (
      <div className='modal-root__modal user-note-modal'>
        <div className='user-note-modal__target'>
          <IconButton className='media-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={16} />
          <FormattedMessage id='user_note.target' defaultMessage='Edit your note for {target}' values={{ target: <strong>{account.get('acct')}</strong> }} />
        </div>

        <div className='user-note-modal__container'>
          <p><FormattedMessage id='user_note.hint' defaultMessage='You can keep some note about that person for yourself (this will not be shared with them):' /></p>

          <textarea
            className='setting-text light'
            placeholder={intl.formatMessage(messages.placeholder)}
            value={comment}
            onChange={this.handleCommentChange}
            onKeyDown={this.handleKeyDown}
            disabled={isSubmitting}
            autoFocus
          />

          <Button text={intl.formatMessage(messages.save)} onClick={this.handleSubmit} disabled={isSubmitting} />
        </div>
      </div>
    );
  }

}
