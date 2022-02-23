import React from 'react';
import { connect } from 'react-redux';
import { submitReport } from 'flavours/glitch/actions/reports';
import { expandAccountTimeline } from 'flavours/glitch/actions/timelines';
import { fetchRules } from 'flavours/glitch/actions/rules';
import { fetchRelationships } from 'flavours/glitch/actions/accounts';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { makeGetAccount } from 'flavours/glitch/selectors';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import { OrderedSet } from 'immutable';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IconButton from 'flavours/glitch/components/icon_button';
import Category from 'flavours/glitch/features/report/category';
import Statuses from 'flavours/glitch/features/report/statuses';
import Rules from 'flavours/glitch/features/report/rules';
import Comment from 'flavours/glitch/features/report/comment';
import Thanks from 'flavours/glitch/features/report/thanks';

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

export default @connect(makeMapStateToProps)
@injectIntl
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
    comment: '',
    category: null,
    selectedRuleIds: OrderedSet(),
    forward: true,
    isSubmitting: false,
    isSubmitted: false,
  };

  handleSubmit = () => {
    const { dispatch, accountId } = this.props;
    const { selectedStatusIds, comment, category, selectedRuleIds, forward } = this.state;

    this.setState({ isSubmitting: true });

    dispatch(submitReport({
      account_id: accountId,
      status_ids: selectedStatusIds.toArray(),
      comment,
      forward,
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

  handleRuleToggle = (ruleId, checked) => {
    const { selectedRuleIds } = this.state;

    if (checked) {
      this.setState({ selectedRuleIds: selectedRuleIds.add(ruleId) });
    } else {
      this.setState({ selectedRuleIds: selectedRuleIds.remove(ruleId) });
    }
  }

  handleChangeCategory = category => {
    this.setState({ category });
  };

  handleChangeComment = comment => {
    this.setState({ comment });
  };

  handleChangeForward = forward => {
    this.setState({ forward });
  };

  handleNextStep = step => {
    this.setState({ step });
  };

  componentDidMount () {
    const { dispatch, accountId } = this.props;

    dispatch(fetchRelationships([accountId]));
    dispatch(expandAccountTimeline(accountId, { withReplies: true }));
    dispatch(fetchRules());
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
      comment,
      forward,
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
          forward={forward}
          domain={domain}
          onChangeComment={this.handleChangeComment}
          onChangeForward={this.handleChangeForward}
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
