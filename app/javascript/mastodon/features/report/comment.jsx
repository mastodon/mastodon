import PropTypes from 'prop-types';
import { useCallback, useEffect, useRef } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import { OrderedSet, List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { shallowEqual } from 'react-redux';
import { createSelector } from 'reselect';

import Toggle from 'react-toggle';

import { fetchAccount } from 'mastodon/actions/accounts';
import Button from 'mastodon/components/button';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  placeholder: { id: 'report.placeholder', defaultMessage: 'Type or paste additional comments' },
});

const selectRepliedToAccountIds = createSelector(
  [
    (state) => state.get('statuses'),
    (_, statusIds) => statusIds,
  ],
  (statusesMap, statusIds) => statusIds.map((statusId) => statusesMap.getIn([statusId, 'in_reply_to_account_id'])),
  {
    resultEqualityCheck: shallowEqual,
  }
);

const Comment = ({ comment, domain, statusIds, isRemote, isSubmitting, selectedDomains, onSubmit, onChangeComment, onToggleDomain }) => {
  const intl = useIntl();

  const dispatch = useAppDispatch();
  const loadedRef = useRef(false);

  const handleClick = useCallback(() => onSubmit(), [onSubmit]);
  const handleChange = useCallback((e) => onChangeComment(e.target.value), [onChangeComment]);
  const handleToggleDomain = useCallback(e => onToggleDomain(e.target.value, e.target.checked), [onToggleDomain]);

  const handleKeyDown = useCallback((e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      handleClick();
    }
  }, [handleClick]);

  // Memoize accountIds since we don't want it to trigger `useEffect` on each render
  const accountIds = useAppSelector((state) => domain ? selectRepliedToAccountIds(state, statusIds) : ImmutableList());

  // While we could memoize `availableDomains`, it is pretty inexpensive to recompute
  const accountsMap = useAppSelector((state) => state.get('accounts'));
  const availableDomains = domain ? OrderedSet([domain]).union(accountIds.map((accountId) => accountsMap.getIn([accountId, 'acct'], '').split('@')[1]).filter(domain => !!domain)) : OrderedSet();

  useEffect(() => {
    if (loadedRef.current) {
      return;
    }

    loadedRef.current = true;

    // First, pre-select known domains
    availableDomains.forEach((domain) => {
      onToggleDomain(domain, true);
    });

    // Then, fetch missing replied-to accounts
    const unknownAccounts = OrderedSet(accountIds.filter(accountId => accountId && !accountsMap.has(accountId)));
    unknownAccounts.forEach((accountId) => {
      dispatch(fetchAccount(accountId));
    });
  });

  return (
    <>
      <h3 className='report-dialog-modal__title'><FormattedMessage id='report.comment.title' defaultMessage='Is there anything else you think we should know?' /></h3>

      <textarea
        className='report-dialog-modal__textarea'
        placeholder={intl.formatMessage(messages.placeholder)}
        value={comment}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        disabled={isSubmitting}
      />

      {isRemote && (
        <>
          <p className='report-dialog-modal__lead'><FormattedMessage id='report.forward_hint' defaultMessage='The account is from another server. Send an anonymized copy of the report there as well?' /></p>

          { availableDomains.map((domain) => (
            <label className='report-dialog-modal__toggle' key={`toggle-${domain}`}>
              <Toggle checked={selectedDomains.includes(domain)} disabled={isSubmitting} onChange={handleToggleDomain} value={domain} />
              <FormattedMessage id='report.forward' defaultMessage='Forward to {target}' values={{ target: domain }} />
            </label>
          ))}
        </>
      )}

      <div className='flex-spacer' />

      <div className='report-dialog-modal__actions'>
        <Button onClick={handleClick} disabled={isSubmitting}><FormattedMessage id='report.submit' defaultMessage='Submit report' /></Button>
      </div>
    </>
  );
}

Comment.propTypes = {
  comment: PropTypes.string.isRequired,
  domain: PropTypes.string,
  statusIds: ImmutablePropTypes.list.isRequired,
  isRemote: PropTypes.bool,
  isSubmitting: PropTypes.bool,
  selectedDomains: ImmutablePropTypes.set.isRequired,
  onSubmit: PropTypes.func.isRequired,
  onChangeComment: PropTypes.func.isRequired,
  onToggleDomain: PropTypes.func.isRequired,
};

export default Comment;
