import React from 'react';
import PropTypes from 'prop-types';
import { injectIntl, FormattedMessage } from 'react-intl';
import Button from '../../../components/button';
import classNames from 'classnames';

export default @injectIntl
class ConfirmationModal extends React.PureComponent {

  static propTypes = {
    message: PropTypes.node.isRequired,
    confirm: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    onConfirm: PropTypes.func.isRequired,
    secondary: PropTypes.string,
    onSecondary: PropTypes.func,
    closeWhenConfirm: PropTypes.bool,
    destructive: PropTypes.bool,
    passphrase: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  static defaultProps = {
    closeWhenConfirm: true,
  };

  state = {
    passphrase: '',
  };

  componentDidMount() {
    if (this.props.passphrase) {
      this.passphraseInput.focus();
    } else {
      this.button.focus();
    }
  }

  handleClick = () => {
    const { passphrase, closeWhenConfirm, onClose, onConfirm } = this.props;

    if (passphrase && this.state.passphrase !== passphrase) {
      this.passphraseInput.focus();
      return;
    }

    if (closeWhenConfirm) {
      onClose();
    }
    onConfirm();
  }

  handleSecondary = () => {
    this.props.onClose();
    this.props.onSecondary();
  }

  handleCancel = () => {
    this.props.onClose();
  }

  handleChange = (e) => {
    this.setState({ passphrase: e.target.value });
  }

  setRef = (c) => {
    this.button = c;
  }

  setPassphraseRef = (c) => {
    this.passphraseInput = c;
  }

  render () {
    const { message, confirm, secondary, destructive, passphrase } = this.props;

    return (
      <div className='modal-root__modal confirmation-modal'>
        <div className='confirmation-modal__container'>
          {message}
        </div>

        {passphrase && (
          <div className='confirmation-modal__passphrase'>
            <div className='passphrase__label'>
              <FormattedMessage id='confirmations.passphrase' defaultMessage='Please type "{passphrase}" to confirm' values={{ passphrase: <strong>{passphrase}</strong> }} />,
            </div>
            <input type='text' className={classNames('passphrase__input', { invalid: this.state.passphrase !== passphrase })} onChange={this.handleChange} ref={this.setPassphraseRef} />
          </div>
        )}

        <div className='confirmation-modal__action-bar'>
          <Button onClick={this.handleCancel} className='confirmation-modal__cancel-button'>
            <FormattedMessage id='confirmation_modal.cancel' defaultMessage='Cancel' />
          </Button>
          {secondary !== undefined && (
            <Button text={secondary} onClick={this.handleSecondary} className='confirmation-modal__secondary-button' />
          )}
          <Button text={confirm} className={classNames({ 'always-destructive': destructive })} onClick={this.handleClick} disabled={passphrase && this.state.passphrase !== passphrase} ref={this.setRef} />
        </div>
      </div>
    );
  }

}
