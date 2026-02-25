import { useCallback, useEffect, useId, useRef } from 'react';

import { useIntl, defineMessages, FormattedMessage } from 'react-intl';

import type { Map } from 'immutable';
import { OrderedSet } from 'immutable';
import { shallowEqual } from 'react-redux';

import Toggle from 'react-toggle';

import { fetchAccount } from 'mastodon/actions/accounts';
import { Button } from 'mastodon/components/button';
import type { Status } from 'mastodon/models/status';
import type { RootState } from 'mastodon/store';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from 'mastodon/store';

const messages = defineMessages({
  placeholder: {
    id: 'report.placeholder',
    defaultMessage: 'Type or paste additional comments',
  },
});

const selectRepliedToAccountIds = createAppSelector(
  [
    (state: RootState) => state.statuses,
    (_: unknown, statusIds: string[]) => statusIds,
  ],
  (statusesMap: Map<string, Status>, statusIds: string[]) =>
    statusIds.map(
      (statusId) =>
        statusesMap.getIn([statusId, 'in_reply_to_account_id']) as string,
    ),
  {
    memoizeOptions: {
      resultEqualityCheck: shallowEqual,
    },
  },
);

interface Props {
  modalTitle?: React.ReactNode;
  comment: string;
  domain?: string;
  statusIds: string[];
  isRemote?: boolean;
  isSubmitting?: boolean;
  selectedDomains: string[];
  submitError?: React.ReactNode;
  onSubmit: () => void;
  onChangeComment: (newComment: string) => void;
  onToggleDomain: (toggledDomain: string, checked: boolean) => void;
}

const Comment: React.FC<Props> = ({
  modalTitle,
  comment,
  domain,
  statusIds,
  isRemote,
  isSubmitting,
  selectedDomains,
  submitError,
  onSubmit,
  onChangeComment,
  onToggleDomain,
}) => {
  const intl = useIntl();

  const dispatch = useAppDispatch();
  const loadedRef = useRef(false);

  const handleSubmit = useCallback(() => {
    onSubmit();
  }, [onSubmit]);

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLTextAreaElement>) => {
      onChangeComment(e.target.value);
    },
    [onChangeComment],
  );

  const handleToggleDomain = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      onToggleDomain(e.target.value, e.target.checked);
    },
    [onToggleDomain],
  );

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
        handleSubmit();
      }
    },
    [handleSubmit],
  );

  // Memoize accountIds since we don't want it to trigger `useEffect` on each render
  const accountIds = useAppSelector((state) =>
    domain ? selectRepliedToAccountIds(state, statusIds) : [],
  );

  // While we could memoize `availableDomains`, it is pretty inexpensive to recompute
  const accountsMap = useAppSelector((state) => state.accounts);

  const availableDomains = domain
    ? OrderedSet([domain]).union(
        accountIds
          .map(
            (accountId) =>
              (accountsMap.getIn([accountId, 'acct'], '') as string).split(
                '@',
              )[1],
          )
          .filter((domain): domain is string => !!domain),
      )
    : OrderedSet<string>();

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
    const unknownAccounts = OrderedSet(
      accountIds.filter(
        (accountId) => accountId && !accountsMap.has(accountId),
      ),
    );
    unknownAccounts.forEach((accountId) => {
      dispatch(fetchAccount(accountId));
    });
  });

  const titleId = useId();

  return (
    <>
      <h3 className='report-dialog-modal__title' id={titleId}>
        {modalTitle ?? (
          <FormattedMessage
            id='report.comment.title'
            defaultMessage='Is there anything else you think we should know?'
          />
        )}
      </h3>

      <textarea
        className='report-dialog-modal__textarea'
        placeholder={intl.formatMessage(messages.placeholder)}
        aria-labelledby={titleId}
        value={comment}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        disabled={isSubmitting}
      />

      {isRemote && (
        <>
          <p className='report-dialog-modal__lead'>
            <FormattedMessage
              id='report.forward_hint'
              defaultMessage='The account is from another server. Send an anonymized copy of the report there as well?'
            />
          </p>

          {availableDomains.map((domain) => (
            <label
              className='report-dialog-modal__toggle'
              key={`toggle-${domain}`}
              htmlFor={`input-${domain}`}
            >
              <Toggle
                checked={selectedDomains.includes(domain)}
                disabled={isSubmitting}
                onChange={handleToggleDomain}
                value={domain}
                id={`input-${domain}`}
              />
              <FormattedMessage
                id='report.forward'
                defaultMessage='Forward to {target}'
                values={{ target: domain }}
              />
            </label>
          ))}
        </>
      )}

      {submitError}

      <div className='flex-spacer' />

      <div className='report-dialog-modal__actions'>
        <Button onClick={handleSubmit} disabled={isSubmitting}>
          <FormattedMessage id='report.submit' defaultMessage='Submit report' />
        </Button>
      </div>
    </>
  );
};

// eslint-disable-next-line import/no-default-export
export default Comment;
