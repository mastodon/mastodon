import React from 'react';
import { connect } from 'react-redux';
import { changeReportComment, submitReport } from '../../../actions/reports';
import { refreshAccountTimeline } from '../../../actions/timelines';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { makeGetAccount } from '../../../selectors';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import StatusCheckBox from '../../report/containers/status_check_box_container';
import Immutable from 'immutable';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Button from '../../../components/button';

const messages = defineMessages({
  placeholder: { id: 'report.placeholder', defaultMessage: 'Additional comments' },
  submit: { id: 'report.submit', defaultMessage: 'Submit' },
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = state => {
    const accountId = state.getIn(['reports', 'new', 'account_id']);

    return {
      isSubmitting: state.getIn(['reports', 'new', 'isSubmitting']),
      account: getAccount(state, accountId),
      comment: state.getIn(['reports', 'new', 'comment']),
      statusIds: Immutable.OrderedSet(state.getIn(['timelines', `account:${accountId}`, 'items'])).union(state.getIn(['reports', 'new', 'status_ids'])),
    };
  };

  return mapStateToProps;
};

@connect(makeMapStateToProps)
@injectIntl
export default class ReportModal extends ImmutablePureComponent {

  static propTypes = {
    isSubmitting: PropTypes.bool,
    account: ImmutablePropTypes.map,
    statusIds: ImmutablePropTypes.orderedSet.isRequired,
    comment: PropTypes.string.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleCommentChange = (e) => {
    this.props.dispatch(changeReportComment(e.target.value));
  }

  handleSubmit = () => {
    this.props.dispatch(submitReport());
  }

  componentDidMount () {
    this.props.dispatch(refreshAccountTimeline(this.props.account.get('id')));
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.account !== nextProps.account && nextProps.account) {
      this.props.dispatch(refreshAccountTimeline(nextProps.account.get('id')));
    }
  }

  render () {
    const { account, comment, intl, statusIds, isSubmitting } = this.props;

    if (!account) {
      return null;
    }

    return (
      <div className='modal-root__modal report-modal'>
        <div className='report-modal__target'>
          <FormattedMessage id='report.target' defaultMessage='Report {target}' values={{ target: <strong>{account.get('acct')}</strong> }} />
        </div>

        <div className='report-modal__container'>
          <div className='report-modal__statuses'>
            <div>
              {statusIds.map(statusId => <StatusCheckBox id={statusId} key={statusId} disabled={isSubmitting} />)}
            </div>
          </div>

          <div className='report-modal__comment'>
            <textarea
              className='setting-text light'
              placeholder={intl.formatMessage(messages.placeholder)}
              value={comment}
              onChange={this.handleCommentChange}
              disabled={isSubmitting}
            />
          </div>
        </div>

        <div className='report-modal__action-bar'>
          <Button disabled={isSubmitting} text={intl.formatMessage(messages.submit)} onClick={this.handleSubmit} />
        </div>
      </div>
    );
  }

}
