import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { defineMessages, injectIntl } from 'react-intl';

import Column from './column';
import ColumnHeader from './column_header';
import ColumnBackButtonSlim from '../../../components/column_back_button_slim';
import IconButton from '../../../components/icon_button';

import { closeModal } from '../../../actions/modal';

const messages = defineMessages({
  failed: { id: 'bundle.fetch_failed', defaultMessage: 'Network error' },
  retry: { id: 'bundle.fetch_retry', defaultMessage: 'Try again' },
  close: { id: 'bundle.modal.close', defaultMessage: 'Close' },
});

const style = {
  display: 'flex',
  flexDirection: 'column',
  justifyContent: 'center',
  alignItems: 'center',
};

class BundleRefetch extends React.Component {

  static propTypes = {
    onLoad: PropTypes.func.isRequired,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  }

  handleRetry = () => {
    this.props.onLoad();
  }

  render () {
    const { multiColumn, intl: { formatMessage } } = this.props;

    return (
      <Column>
        <ColumnHeader icon='exclamation-circle' type={formatMessage(messages.failed)} multiColumn={multiColumn} />
        <ColumnBackButtonSlim />
        <div className='scrollable' style={style}>
          <IconButton title={formatMessage(messages.retry)} icon='refresh' onClick={this.handleRetry} size={64} />
        </div>
      </Column>
    );
  }

}

class ModalRefetch extends React.Component {

  static propTypes = {
    onLoad: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  }

  handleRetry = () => {
    this.props.onLoad();
  }

  render () {
    const { onClose, intl: { formatMessage } } = this.props;

    return (
      <div className='modal-root__modal onboarding-modal'>
        <div className='onboarding-modal__pager' style={style}>
          <IconButton title={formatMessage(messages.retry)} icon='refresh' onClick={this.handleRetry} size={64} />
          {formatMessage(messages.failed)}
        </div>

        <div className='onboarding-modal__paginator' style={{ justifyContent: 'center' }}>
          <div>
            <button
              onClick={onClose}
              className='onboarding-modal__nav onboarding-modal__skip'
            >
              {formatMessage(messages.close)}
            </button>
          </div>
        </div>
      </div>
    );
  }

}

const mapDispatchToProps = dispatch => ({
  onClose: () => dispatch(closeModal()),
});

export default injectIntl(BundleRefetch);
export const ModalBundleRefetch = injectIntl(connect(null, mapDispatchToProps)(ModalRefetch));
