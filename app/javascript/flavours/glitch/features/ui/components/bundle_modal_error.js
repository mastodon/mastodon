import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

import IconButton from 'flavours/glitch/components/icon_button';

const messages = defineMessages({
  error: { id: 'bundle_modal_error.message', defaultMessage: 'Something went wrong while loading this component.' },
  retry: { id: 'bundle_modal_error.retry', defaultMessage: 'Try again' },
  close: { id: 'bundle_modal_error.close', defaultMessage: 'Close' },
});

class BundleModalError extends React.Component {

  static propTypes = {
    onRetry: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  }

  handleRetry = () => {
    this.props.onRetry();
  }

  render () {
    const { onClose, intl: { formatMessage } } = this.props;

    // Keep the markup in sync with <ModalLoading />
    // (make sure they have the same dimensions)
    return (
      <div className='modal-root__modal error-modal'>
        <div className='error-modal__body'>
          <IconButton title={formatMessage(messages.retry)} icon='refresh' onClick={this.handleRetry} size={64} />
          {formatMessage(messages.error)}
        </div>

        <div className='error-modal__footer'>
          <div>
            <button
              onClick={onClose}
              className='error-modal__nav onboarding-modal__skip'
            >
              {formatMessage(messages.close)}
            </button>
          </div>
        </div>
      </div>
    );
  }

}

export default injectIntl(BundleModalError);
