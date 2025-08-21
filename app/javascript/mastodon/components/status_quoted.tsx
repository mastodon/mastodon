import { useEffect, useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { Map as ImmutableMap } from 'immutable';

import { LearnMoreLink } from 'mastodon/components/learn_more_link';
import StatusContainer from 'mastodon/containers/status_container';
import type { Status } from 'mastodon/models/status';
import type { RootState } from 'mastodon/store';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { fetchStatus } from '../actions/statuses';
import { makeGetStatus } from '../selectors';

const MAX_QUOTE_POSTS_NESTING_LEVEL = 1;

const QuoteWrapper: React.FC<{
  isError?: boolean;
  children: React.ReactElement;
}> = ({ isError, children }) => {
  return (
    <div
      className={classNames('status__quote', {
        'status__quote--error': isError,
      })}
    >
      {children}
    </div>
  );
};

const NestedQuoteLink: React.FC<{
  status: Status;
}> = ({ status }) => {
  const accountId = status.get('account') as string;
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );

  const quoteAuthorName = account?.acct;

  if (!quoteAuthorName) {
    return null;
  }

  return (
    <div className='status__quote-author-button'>
      <FormattedMessage
        id='status.quote_post_author'
        defaultMessage='Quoted a post by @{name}'
        values={{ name: quoteAuthorName }}
      />
    </div>
  );
};

type QuoteMap = ImmutableMap<'state' | 'quoted_status', string | null>;
type GetStatusSelector = (
  state: RootState,
  props: { id?: string | null; contextType?: string },
) => Status | null;

interface QuotedStatusProps {
  quote: QuoteMap;
  contextType?: string;
  variant?: 'full' | 'link';
  nestingLevel?: number;
  onQuoteCancel?: () => void; // Used for composer.
}

export const QuotedStatus: React.FC<QuotedStatusProps> = ({
  quote,
  contextType,
  nestingLevel = 1,
  variant = 'full',
  onQuoteCancel,
}) => {
  const dispatch = useAppDispatch();
  const quotedStatusId = quote.get('quoted_status');
  const quoteState = quote.get('state');
  const status = useAppSelector((state) =>
    quotedStatusId ? state.statuses.get(quotedStatusId) : undefined,
  );

  useEffect(() => {
    if (!status && quotedStatusId) {
      dispatch(fetchStatus(quotedStatusId));
    }
  }, [status, quotedStatusId, dispatch]);

  // In order to find out whether the quoted post should be completely hidden
  // due to a matching filter, we run it through the selector used by `status_container`.
  // If this returns null even though `status` exists, it's because it's filtered.
  const getStatus = useMemo(() => makeGetStatus(), []) as GetStatusSelector;
  const statusWithExtraData = useAppSelector((state) =>
    getStatus(state, { id: quotedStatusId, contextType }),
  );
  const isFilteredAndHidden = status && statusWithExtraData === null;

  let quoteError: React.ReactNode = null;

  if (isFilteredAndHidden) {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.filtered'
        defaultMessage='Hidden due to one of your filters'
      />
    );
  } else if (quoteState === 'pending') {
    quoteError = (
      <>
        <FormattedMessage
          id='status.quote_error.pending_approval'
          defaultMessage='Post pending'
        />

        <LearnMoreLink>
          <h6>
            <FormattedMessage
              id='status.quote_error.pending_approval_popout.title'
              defaultMessage='Pending quote? Remain calm'
            />
          </h6>
          <p>
            <FormattedMessage
              id='status.quote_error.pending_approval_popout.body'
              defaultMessage='Quotes shared across the Fediverse may take time to display, as different servers have different protocols.'
            />
          </p>
        </LearnMoreLink>
      </>
    );
  } else if (
    !status ||
    !quotedStatusId ||
    quoteState === 'deleted' ||
    quoteState === 'rejected' ||
    quoteState === 'revoked' ||
    quoteState === 'unauthorized'
  ) {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.not_available'
        defaultMessage='Post unavailable'
      />
    );
  }

  if (quoteError) {
    return <QuoteWrapper isError>{quoteError}</QuoteWrapper>;
  }

  if (variant === 'link' && status) {
    return <NestedQuoteLink status={status} />;
  }

  const childQuote = status?.get('quote') as QuoteMap | undefined;
  const canRenderChildQuote =
    childQuote && nestingLevel <= MAX_QUOTE_POSTS_NESTING_LEVEL;

  return (
    <QuoteWrapper>
      {/* @ts-expect-error Status is not yet typed */}
      <StatusContainer
        isQuotedPost
        id={quotedStatusId}
        contextType={contextType}
        avatarSize={32}
        onQuoteCancel={onQuoteCancel}
      >
        {canRenderChildQuote && (
          <QuotedStatus
            quote={childQuote}
            contextType={contextType}
            variant={
              nestingLevel === MAX_QUOTE_POSTS_NESTING_LEVEL ? 'link' : 'full'
            }
            nestingLevel={nestingLevel + 1}
          />
        )}
      </StatusContainer>
    </QuoteWrapper>
  );
};

interface StatusQuoteManagerProps {
  id: string;
  contextType?: string;
  [key: string]: unknown;
}

/**
 * This wrapper component takes a status ID and, if the associated status
 * is a quote post, it renders the quote into `StatusContainer` as a child.
 * It passes all other props through to `StatusContainer`.
 */

export const StatusQuoteManager = (props: StatusQuoteManagerProps) => {
  const status = useAppSelector((state) => {
    const status = state.statuses.get(props.id);
    const reblogId = status?.get('reblog') as string | undefined;
    return reblogId ? state.statuses.get(reblogId) : status;
  });
  const quote = status?.get('quote') as QuoteMap | undefined;

  if (quote) {
    return (
      <StatusContainer {...props}>
        <QuotedStatus quote={quote} contextType={props.contextType} />
      </StatusContainer>
    );
  }

  return <StatusContainer {...props} />;
};
