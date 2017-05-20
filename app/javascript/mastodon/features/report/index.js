import React from 'react';
import { connect } from 'react-redux';
import { cancelReport, changeReportComment, submitReport } from '../../actions/reports';
import { fetchAccountTimeline } from '../../actions/accounts';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Column from '../ui/components/column';
import Button from '../../components/button';
import { makeGetAccount } from '../../selectors';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import StatusCheckBox from './containers/status_check_box_container';
import Immutable from 'immutable';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';

const messages = defineMessages({
  heading: { id: 'report.heading', defaultMessage: 'New report' },
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
      statusIds: Immutable.OrderedSet(state.getIn(['timelines', 'accounts_timelines', accountId, 'items'])).union(state.getIn(['reports', 'new', 'status_ids'])),
    };
  };

  return mapStateToProps;
};

class Report extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    isSubmitting: PropTypes.bool,
    account: ImmutablePropTypes.map,
    statusIds: ImmutablePropTypes.orderedSet.isRequired,
    comment: PropTypes.string.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    if (!this.props.account) {
      this.context.router.replace('/');
    }
  }

  componentDidMount () {
    if (!this.props.account) {
      return;
    }

    this.props.dispatch(fetchAccountTimeline(this.props.account.get('id')));
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.account !== nextProps.account && nextProps.account) {
      this.props.dispatch(fetchAccountTimeline(nextProps.account.get('id')));
    }
  }

  handleCommentChange = (e) => {
    this.props.dispatch(changeReportComment(e.target.value));
  }

  handleSubmit = () => {
    this.props.dispatch(submitReport());
    this.context.router.replace('/');
  }

  render () {
    const { account, comment, intl, statusIds, isSubmitting } = this.props;

    if (!account) {
      return null;
    }

    return (
      <Column heading={intl.formatMessage(messages.heading)} icon='flag'>
        <ColumnBackButtonSlim />

        <div className='report scrollable'>
          <div className='report__target'>
            <FormattedMessage id='report.target' defaultMessage='Reporting' />
            <strong>{account.get('acct')}</strong>
          </div>

          <div className='scrollable report__statuses'>
            <div>
              {statusIds.map(statusId => <StatusCheckBox id={statusId} key={statusId} disabled={isSubmitting} />)}
            </div>
          </div>

          <div className='report__textarea-wrapper'>
            <textarea
              className='report__textarea'
              placeholder={intl.formatMessage(messages.placeholder)}
              value={comment}
              onChange={this.handleCommentChange}
              disabled={isSubmitting}
            />

            <div className='report__submit'>
              <div className='report__submit-button'><Button disabled={isSubmitting} text={intl.formatMessage(messages.submit)} onClick={this.handleSubmit} /></div>
            </div>
          </div>
        </div>
      </Column>
    );
  }

}

export default connect(makeMapStateToProps)(injectIntl(Report));
