import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { ReactComponent as CloseIcon } from '@material-symbols/svg-600/outlined/close.svg';

import { fetchAccount } from 'mastodon/actions/accounts';
import { fetchFilters, createFilter, createFilterAccount } from 'mastodon/actions/filters';
import { IconButton } from 'mastodon/components/icon_button';

import AddedToFilter from './added_to_filter';
import { CustomFilterTypes } from './custom_filter_types';
import Filters from './filters';
import NewFilter from './new_filter';

const messages = defineMessages({
  title:          { id: 'custom_filters_modal.filters.title',          defaultMessage: 'Filter this {entity}' },
  account_entity: { id: 'custom_filters_modal.filters.entity.account', defaultMessage: 'account' },
  close:          { id: 'lightbox.close',                              defaultMessage: 'Close' },
});

class CustomFilterAccountModal extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    filterType: PropTypes.oneOf(CustomFilterTypes).isRequired,
    contextType: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    step: 'select',
    newFilterTitle: null,
    filterId: null,
    isSubmitting: false,
    isSubmitted: false,
  };

  handleNewFilterSuccess = (result) => {
    this.handleSelectFilter(result.id);
  };

  handleSuccess = () => {
    const { dispatch, accountId } = this.props;
    dispatch(fetchAccount(accountId, true));
    this.setState({ isSubmitting: false, isSubmitted: true, step: 'submitted' });
  };

  handleFail = () => {
    this.setState({ isSubmitting: false });
  };

  handleNextStep = step => {
    this.setState({ step });
  };

  handleSelectFilter = (filterId) => {
    const { dispatch, accountId } = this.props;

    this.setState({ isSubmitting: true, filterId });

    dispatch(createFilterAccount({
      filter_id: filterId,
      target_account_id: accountId,
    }, this.handleSuccess, this.handleFail));
  };

  handleNewFilter = (titlle) => {
    this.setState({ newFilterTitle: titlle, step: 'create' });
  };

  handleCreateFilter = (title, context, action) => {
    const { dispatch } = this.props;

    this.setState({ isSubmitting: true });

    dispatch(createFilter({
      title,
      context: context,
      filter_action: action,
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
      newFilterTitle,
    } = this.state;

    let stepComponent;

    switch(step) {
    case 'select':
      stepComponent = (
        <Filters
          filterType={CustomFilterTypes.Account}
          contextType={contextType}
          onSelectFilter={this.handleSelectFilter}
          onNewFilter={this.handleNewFilter}
        />
      );
      break;
    case 'create':
      stepComponent = (
        <NewFilter
          title={newFilterTitle}
          onSubmit={this.handleCreateFilter}
        />
      );
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
          <FormattedMessage {...messages.title} values={{entity: intl.formatMessage(messages.account_entity)}} />
        </div>

        <div className='report-dialog-modal__container'>
          {stepComponent}
        </div>
      </div>
    );
  }

}

export default connect()(injectIntl(CustomFilterAccountModal));
