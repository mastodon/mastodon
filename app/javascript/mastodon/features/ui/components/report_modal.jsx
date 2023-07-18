import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';

import { OrderedSet } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { submitReport } from 'mastodon/actions/reports';
import { fetchServer } from 'mastodon/actions/server';
import { expandAccountTimeline } from 'mastodon/actions/timelines';
import { IconButton } from 'mastodon/components/icon_button';
import Category from 'mastodon/features/report/category';
import Comment from 'mastodon/features/report/comment';
import Rules from 'mastodon/features/report/rules';
import Statuses from 'mastodon/features/report/statuses';
import Thanks from 'mastodon/features/report/thanks';
import { makeGetAccount } from 'mastodon/selectors';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, { accountId }) => ({
    account: getAccount(state, accountId),
  });

  return mapStateToProps;
};

class ReportModal extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    statusId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    account: ImmutablePropTypes.map.isRequired,
  };

  state = {
    step: 'category',
    selectedStatusIds: OrderedSet(this.props.statusId ? [this.props.statusId] : []),
    selectedDomains: OrderedSet(),
    comment: '',
    category: null,
    selectedRuleIds: OrderedSet(),
    isSubmitting: false,
    isSubmitted: false,
  };

  handleSubmit = () => {
    const { dispatch, accountId } = this.props;
    const { selectedStatusIds, selectedDomains, comment, category, selectedRuleIds } = this.state;

    this.setState({ isSubmitting: true });

    dispatch(submitReport({
      account_id: accountId,
      status_ids: selectedStatusIds.toArray(),
      selected_domains: selectedDomains.toArray(),
      comment,
      forward: selectedDomains.size > 0,
      category,
      rule_ids: selectedRuleIds.toArray(),
    }, this.handleSuccess, this.handleFail));
  };

  handleSuccess = () => {
    this.setState({ isSubmitting: false, isSubmitted: true, step: 'thanks' });
  };

  handleFail = () => {
    this.setState({ isSubmitting: false });
  };

  handleStatusToggle = (statusId, checked) => {
    const { selectedStatusIds } = this.state;

    if (checked) {
      this.setState({ selectedStatusIds: selectedStatusIds.add(statusId) });
    } else {
      this.setState({ selectedStatusIds: selectedStatusIds.remove(statusId) });
    }
  };

  handleDomainToggle = (domain, checked) => {
    if (checked) {
      this.setState((state) => ({ selectedDomains: state.selectedDomains.add(domain) }));
    } else {
      this.setState((state) => ({ selectedDomains: state.selectedDomains.remove(domain) }));
    }
  };

  handleRuleToggle = (ruleId, checked) => {
    if (checked) {
      this.setState((state) => ({ selectedRuleIds: state.selectedRuleIds.add(ruleId) }));
    } else {
      this.setState((state) => ({ selectedRuleIds: state.selectedRuleIds.remove(ruleId) }));
    }
  };

  handleChangeCategory = category => {
    this.setState({ category });
  };

  handleChangeComment = comment => {
    this.setState({ comment });
  };

  handleNextStep = step => {
    this.setState({ step });
  };

  componentDidMount () {
    const { dispatch, accountId } = this.props;

    dispatch(expandAccountTimeline(accountId, { withReplies: true }));
    dispatch(fetchServer());
  }

  render () {
    const {
      accountId,
      account,
      intl,
      onClose,
    } = this.props;

    if (!account) {
      return null;
    }

    const {
      step,
      selectedStatusIds,
      selectedRuleIds,
      selectedDomains,
      comment,
      category,
      isSubmitting,
      isSubmitted,
    } = this.state;

    const domain   = account.get('acct').split('@')[1];
    const isRemote = !!domain;

    let stepComponent;

    switch(step) {
    case 'category':
      stepComponent = (
        <Category
          onNextStep={this.handleNextStep}
          startedFrom={this.props.statusId ? 'status' : 'account'}
          category={category}
          onChangeCategory={this.handleChangeCategory}
        />
      );
      break;
    case 'rules':
      stepComponent = (
        <Rules
          onNextStep={this.handleNextStep}
          selectedRuleIds={selectedRuleIds}
          onToggle={this.handleRuleToggle}
        />
      );
      break;
    case 'statuses':
      stepComponent = (
        <Statuses
          onNextStep={this.handleNextStep}
          accountId={accountId}
          selectedStatusIds={selectedStatusIds}
          onToggle={this.handleStatusToggle}
        />
      );
      break;
    case 'comment':
      stepComponent = (
        <Comment
          onSubmit={this.handleSubmit}
          isSubmitting={isSubmitting}
          isRemote={isRemote}
          comment={comment}
          domain={domain}
          onChangeComment={this.handleChangeComment}
          statusIds={selectedStatusIds}
          selectedDomains={selectedDomains}
          onToggleDomain={this.handleDomainToggle}
        />
      );
      break;
    case 'thanks':
      stepComponent = (
        <Thanks
          submitted={isSubmitted}
          account={account}
          onClose={onClose}
        />
      );
    }

    return (
      <div className='modal-root__modal report-dialog-modal'>
        <div className='report-modal__target'>
          <IconButton className='report-modal__close' title={intl.formatMessage(messages.close)} icon='times' onClick={onClose} size={20} />
          <FormattedMessage id='report.target' defaultMessage='Report {target}' values={{ target: <strong>{account.get('acct')}</strong> }} />
        </div>

        <div className='report-dialog-modal__container'>
          {stepComponent}
        </div>
      </div>
    );
  }

}

export default connect(makeMapStateToProps)(injectIntl(ReportModal));
