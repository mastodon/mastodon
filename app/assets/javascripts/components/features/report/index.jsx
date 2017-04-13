import { connect } from 'react-redux';
import { cancelReport, changeReportComment, submitReport } from '../../actions/reports';
import { fetchAccountTimeline } from '../../actions/accounts';
import PureRenderMixin from 'react-addons-pure-render-mixin';
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
  submit: { id: 'report.submit', defaultMessage: 'Submit' }
});

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = state => {
    const accountId = state.getIn(['reports', 'new', 'account_id']);

    return {
      isSubmitting: state.getIn(['reports', 'new', 'isSubmitting']),
      account: getAccount(state, accountId),
      comment: state.getIn(['reports', 'new', 'comment']),
      statusIds: Immutable.OrderedSet(state.getIn(['timelines', 'accounts_timelines', accountId, 'items'])).union(state.getIn(['reports', 'new', 'status_ids']))
    };
  };

  return mapStateToProps;
};

const textareaStyle = {
  marginBottom: '10px'
};

const Report = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    isSubmitting: React.PropTypes.bool,
    account: ImmutablePropTypes.map,
    statusIds: ImmutablePropTypes.orderedSet.isRequired,
    comment: React.PropTypes.string.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    if (!this.props.account) {
      this.context.router.replace('/');
    }
  },

  componentDidMount () {
    if (!this.props.account) {
      return;
    }

    this.props.dispatch(fetchAccountTimeline(this.props.account.get('id')));
  },

  componentWillReceiveProps (nextProps) {
    if (this.props.account !== nextProps.account && nextProps.account) {
      this.props.dispatch(fetchAccountTimeline(nextProps.account.get('id')));
    }
  },

  handleCommentChange (e) {
    this.props.dispatch(changeReportComment(e.target.value));
  },

  handleSubmit () {
    this.props.dispatch(submitReport());
    this.context.router.replace('/');
  },

  render () {
    const { account, comment, intl, statusIds, isSubmitting } = this.props;

    if (!account) {
      return null;
    }

    return (
      <Column heading={intl.formatMessage(messages.heading)} icon='flag'>
        <ColumnBackButtonSlim />

        <div className='report scrollable' style={{ display: 'flex', flexDirection: 'column', maxHeight: '100%', boxSizing: 'border-box' }}>
          <div className='report__target' style={{ flex: '0 0 auto', padding: '10px' }}>
            <FormattedMessage id='report.target' defaultMessage='Reporting' />
            <strong>{account.get('acct')}</strong>
          </div>

          <div style={{ flex: '1 1 auto' }} className='scrollable'>
            <div>
              {statusIds.map(statusId => <StatusCheckBox id={statusId} key={statusId} disabled={isSubmitting} />)}
            </div>
          </div>

          <div style={{ flex: '0 0 100px', padding: '10px' }}>
            <textarea
              className='report__textarea'
              placeholder={intl.formatMessage(messages.placeholder)}
              value={comment}
              onChange={this.handleCommentChange}
              style={textareaStyle}
              disabled={isSubmitting}
            />

            <div style={{ marginTop: '10px', overflow: 'hidden' }}>
              <div style={{ float: 'right' }}><Button disabled={isSubmitting} text={intl.formatMessage(messages.submit)} onClick={this.handleSubmit} /></div>
            </div>
          </div>
        </div>
      </Column>
    );
  }

});

export default connect(makeMapStateToProps)(injectIntl(Report));
