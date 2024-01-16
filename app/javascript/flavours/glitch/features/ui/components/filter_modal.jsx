import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';


import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { fetchFilters, createFilter, createFilterStatus } from 'flavours/glitch/actions/filters';
import { fetchStatus } from 'flavours/glitch/actions/statuses';
import { IconButton } from 'flavours/glitch/components/icon_button';
import AddedToFilter from 'flavours/glitch/features/filters/added_to_filter';
import SelectFilter from 'flavours/glitch/features/filters/select_filter';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

class FilterModal extends ImmutablePureComponent {

  static propTypes = {
    statusId: PropTypes.string.isRequired,
    contextType: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    step: 'select',
    filterId: null,
    isSubmitting: false,
    isSubmitted: false,
  };

  handleNewFilterSuccess = (result) => {
    this.handleSelectFilter(result.id);
  };

  handleSuccess = () => {
    const { dispatch, statusId } = this.props;
    dispatch(fetchStatus(statusId, true));
    this.setState({ isSubmitting: false, isSubmitted: true, step: 'submitted' });
  };

  handleFail = () => {
    this.setState({ isSubmitting: false });
  };

  handleNextStep = step => {
    this.setState({ step });
  };

  handleSelectFilter = (filterId) => {
    const { dispatch, statusId } = this.props;

    this.setState({ isSubmitting: true, filterId });

    dispatch(createFilterStatus({
      filter_id: filterId,
      status_id: statusId,
    }, this.handleSuccess, this.handleFail));
  };

  handleNewFilter = (title) => {
    const { dispatch } = this.props;

    this.setState({ isSubmitting: true });

    dispatch(createFilter({
      title,
      context: ['home', 'notifications', 'public', 'thread', 'account'],
      action: 'warn',
    }, this.handleNewFilterSuccess, this.handleFail));
  };

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(fetchFilters());
  }

  render () {
    const {
      intl,
      statusId,
      contextType,
      onClose,
    } = this.props;

    const {
      step,
      filterId,
    } = this.state;

    let stepComponent;

    switch(step) {
    case 'select':
      stepComponent = (
        <SelectFilter
          contextType={contextType}
          onSelectFilter={this.handleSelectFilter}
          onNewFilter={this.handleNewFilter}
        />
      );
      break;
    case 'create':
      stepComponent = null;
      break;
    case 'submitted':
      stepComponent = (
        <AddedToFilter
          contextType={contextType}
          filterId={filterId}
          statusId={statusId}
          onClose={onClose}
        />
      );
    }

    return (
      <div className='modal-root__modal report-dialog-modal'>
        <div className='report-modal__target'>
          <IconButton className='report-modal__close' title={intl.formatMessage(messages.close)} icon='times' iconComponent={CloseIcon} onClick={onClose} size={20} />
          <FormattedMessage id='filter_modal.title.status' defaultMessage='Filter a post' />
        </div>

        <div className='report-dialog-modal__container'>
          {stepComponent}
        </div>
      </div>
    );
  }

}

export default connect()(injectIntl(FilterModal));
