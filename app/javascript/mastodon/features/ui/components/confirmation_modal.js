import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Button from '../../../components/button';

class ConfirmationModal extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleClick = this.handleClick.bind(this);
    this.handleCancel = this.handleCancel.bind(this);
  }

  handleClick () {
    this.props.onClose();
    this.props.onConfirm();
  }

  handleCancel (e) {
    e.preventDefault();
    this.props.onClose();
  }

  render () {
    const { intl, message, confirm, onConfirm, onClose } = this.props;

    return (
      <div className='modal-root__modal confirmation-modal'>
        <div className='confirmation-modal__container'>
          {message}
        </div>

        <div className='confirmation-modal__action-bar'>
          <div><a href='#' onClick={this.handleCancel}><FormattedMessage id='confirmation_modal.cancel' defaultMessage='Cancel' /></a></div>
          <Button text={confirm} onClick={this.handleClick} />
        </div>
      </div>
    );
  }

}

ConfirmationModal.propTypes = {
  message: PropTypes.node.isRequired,
  confirm: PropTypes.string.isRequired,
  onClose: PropTypes.func.isRequired,
  onConfirm: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(ConfirmationModal);
