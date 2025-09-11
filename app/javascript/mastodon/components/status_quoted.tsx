import { useEffect, useMemo, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { Map as ImmutableMap } from 'immutable';

import { LearnMoreLink } from 'mastodon/components/learn_more_link';
import StatusContainer from 'mastodon/containers/status_container';
import type { Status } from 'mastodon/models/status';
import type { RootState } from 'mastodon/store';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { fetchStatus } from '../actions/statuses';
import { makeGetStatusWithExtraInfo } from '../selectors';

import { Button } from './button';

const MAX_QUOTE_POSTS_NESTING_LEVEL = 1;

const QuoteWrapper: React.FC<{
  isError?: boolean;
  contextType?: string;
  onQuoteCancel?: () => void;
  children: React.ReactElement;
}> = ({ isError, contextType, onQuoteCancel, children }) => {
  return (
    <div
      className={classNames('status__quote', {
        'status__quote--error': isError,
      })}
    >
      {children}
      {contextType === 'composer' && (
        <Button compact plain onClick={onQuoteCancel}>
          <FormattedMessage id='status.remove_quote' defaultMessage='Remove' />
        </Button>
      )}
    </div>
  );
};

const NestedQuoteLink: React.FC<{ status: Status }> = ({ status }) => {
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

type GetStatusSelector = (
  state: RootState,
  props: { id?: string | null; contextType?: string },
) => {
  status: Status | null;
  loadingState: 'not-found' | 'loading' | 'filtered' | 'complete';
};

type QuoteMap = ImmutableMap<'state' | 'quoted_status', string | null>;

interface QuotedStatusProps {
  quote: QuoteMap;
  contextType?: string;
  parentQuotePostId?: string | null;
  variant?: 'full' | 'link';
  nestingLevel?: number;
  onQuoteCancel?: () => void; // Used for composer.
}

export const QuotedStatus: React.FC<QuotedStatusProps> = ({
  quote,
  contextType,
  parentQuotePostId,
  nestingLevel = 1,
  variant = 'full',
  onQuoteCancel,
}) => {
  const dispatch = useAppDispatch();
  const quoteState = useAppSelector((state) =>
    parentQuotePostId
      ? state.statuses.getIn([parentQuotePostId, 'quote', 'state'])
      : quote.get('state'),
  );

  const quotedStatusId = quote.get('quoted_status');
  const getStatusSelector = useMemo(
    () => makeGetStatusWithExtraInfo() as GetStatusSelector,
    [],
  );
  const { status, loadingState } = useAppSelector((state) =>
    getStatusSelector(state, { id: quotedStatusId, contextType }),
  );

  const shouldFetchQuote =
    !status?.get('isLoading') &&
    quoteState !== 'deleted' &&
    loadingState === 'not-found';
  const isLoaded = loadingState === 'complete';

  const isFetchingQuoteRef = useRef(false);

  useEffect(() => {
    if (isLoaded) {
      isFetchingQuoteRef.current = false;
    }
  }, [isLoaded]);

  useEffect(() => {
    if (shouldFetchQuote && quotedStatusId && !isFetchingQuoteRef.current) {
      dispatch(
        fetchStatus(quotedStatusId, {
          parentQuotePostId,
          alsoFetchContext: false,
        }),
      );
      isFetchingQuoteRef.current = true;
    }
  }, [shouldFetchQuote, quotedStatusId, parentQuotePostId, dispatch]);

  const isFilteredAndHidden = loadingState === 'filtered';

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
          <p>
            <FormattedMessage
              id='status.quote_error.pending_approval_popout.body'
              defaultMessage="On Mastodon, you can control whether someone can quote you. This post is pending while we're getting the original author's approval."
            />
          </p>
        </LearnMoreLink>
      </>
    );
  } else if (quoteState === 'revoked') {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.revoked'
        defaultMessage='Post removed by author'
      />
    );
  } else if (
    !status ||
    !quotedStatusId ||
    quoteState === 'deleted' ||
    quoteState === 'rejected' ||
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
    return (
      <QuoteWrapper
        isError
        contextType={contextType}
        onQuoteCancel={onQuoteCancel}
      >
        {quoteError}
      </QuoteWrapper>
    );
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
            parentQuotePostId={quotedStatusId}
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
        <QuotedStatus
          quote={quote}
          parentQuotePostId={status?.get('id') as string}
          contextType={props.contextType}
        />
      </StatusContainer>
    );
  }

  return <StatusContainer {...props} />;
};
