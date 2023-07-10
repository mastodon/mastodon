import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

import { OrderedSet } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { createSelector } from 'reselect';

import Toggle from 'react-toggle';

import { fetchAccount } from 'mastodon/actions/accounts';
import Button from 'mastodon/components/button';

const messages = defineMessages({
  placeholder: { id: 'report.placeholder', defaultMessage: 'Type or paste additional comments' },
});

const getAvailableDomains = createSelector([
  state => state.get('statuses'),
  state => state.get('accounts'),
  (_, { domain }) => domain,
  (_, { statusIds }) => statusIds,
], (statusMap, accountMap, domain, statusIds) => {
  return OrderedSet([domain]).union(
    statusIds.map((statusId) =>
      accountMap.getIn([statusMap.getIn([statusId, 'in_reply_to_account_id']), 'acct'], '').split('@')[1]
    ).filter(domain => !!domain)
  );
});

const mapStateToProps = (state, { domain, statusIds }) => ({
  availableDomains: getAvailableDomains(state, { domain, statusIds }),
});

const mapDispatchToProps = (dispatch, { statusIds }) => ({
  fetchUnknownAccounts() {
    dispatch((_, getState) => {
      const state = getState();
      const statusMap = state.get('statuses');
      const accountMap = state.get('accounts');

      const unknownAccounts = OrderedSet(
        statusIds.map(statusId => statusMap.getIn([statusId, 'in_reply_to_account_id']))
                 .filter(accountId => accountId && !accountMap.has(accountId))
      );

      unknownAccounts.forEach((accountId) => {
        dispatch(fetchAccount(accountId));
      });
    });
  },
});

class Comment extends PureComponent {

  static propTypes = {
    onSubmit: PropTypes.func.isRequired,
    comment: PropTypes.string.isRequired,
    onChangeComment: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    isSubmitting: PropTypes.bool,
    selectedDomains: ImmutablePropTypes.set.isRequired,
    isRemote: PropTypes.bool,
    domain: PropTypes.string,
    onToggleDomain: PropTypes.func.isRequired,
    availableDomains: ImmutablePropTypes.set.isRequired,
    fetchUnknownAccounts: PropTypes.func.isRequired,
  };

  handleClick = () => {
    const { onSubmit } = this.props;
    onSubmit();
  };

  handleChange = e => {
    const { onChangeComment } = this.props;
    onChangeComment(e.target.value);
  };

  handleKeyDown = e => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleClick();
    }
  };

  handleToggleDomain = e => {
    const { onToggleDomain } = this.props;
    onToggleDomain(e.target.value, e.target.checked);
  };

  componentDidMount () {
    this.props.fetchUnknownAccounts();
  }

  render () {
    const { comment, isRemote, availableDomains, selectedDomains, isSubmitting, intl } = this.props;

    return (
      <>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.comment.title' defaultMessage='Is there anything else you think we should know?' /></h3>

        <textarea
          className='report-dialog-modal__textarea'
          placeholder={intl.formatMessage(messages.placeholder)}
          value={comment}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyDown}
          disabled={isSubmitting}
        />

        {isRemote && (
          <>
            <p className='report-dialog-modal__lead'><FormattedMessage id='report.forward_hint' defaultMessage='The account is from another server. Send an anonymized copy of the report there as well?' /></p>

            { availableDomains.map((domain) => (
              <label className='report-dialog-modal__toggle' key={`toggle-${domain}`}>
                <Toggle checked={selectedDomains.includes(domain)} disabled={isSubmitting} onChange={this.handleToggleDomain} value={domain} />
                <FormattedMessage id='report.forward' defaultMessage='Forward to {target}' values={{ target: domain }} />
              </label>
            ))}
          </>
        )}

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleClick} disabled={isSubmitting}><FormattedMessage id='report.submit' defaultMessage='Submit report' /></Button>
        </div>
      </>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(Comment));
