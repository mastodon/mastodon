import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { Map as ImmutableMap } from 'immutable';

import { Icon } from 'mastodon/components/icon';
import StatusContainer from 'mastodon/containers/status_container';
import { useAppSelector } from 'mastodon/store';

import QuoteIcon from '../../images/quote.svg?react';

const QuoteWrapper: React.FC<{
  isError?: boolean;
  children: React.ReactNode;
}> = ({ isError, children }) => {
  return (
    <div
      className={classNames('status__quote', {
        'status__quote--error': isError,
      })}
    >
      <Icon id='quote' icon={QuoteIcon} className='status__quote-icon' />
      {children}
    </div>
  );
};

type QuoteMap = ImmutableMap<'state' | 'quoted_status', string | null>;

export const QuotedStatus: React.FC<{ quote: QuoteMap }> = ({ quote }) => {
  const quotedStatusId = quote.get('quoted_status');
  const state = quote.get('state');
  const status = useAppSelector((state) =>
    quotedStatusId ? state.statuses.get(quotedStatusId) : undefined,
  );

  let quoteError: React.ReactNode | null = null;

  if (state === 'deleted') {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.removed'
        defaultMessage='This post was removed by its author.'
      />
    );
  } else if (state === 'unauthorized') {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.unauthorized'
        defaultMessage='This post cannot be displayed as you are not authorized to view it.'
      />
    );
  } else if (state === 'pending') {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.pending_approval'
        defaultMessage='This post is pending approval from the original author.'
      />
    );
  } else if (state === 'rejected' || state === 'revoked') {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.rejected'
        defaultMessage='This post cannot be displayed as the original author does not allow it to be quoted.'
      />
    );
  } else if (!status || !quotedStatusId) {
    quoteError = (
      <FormattedMessage
        id='status.quote_error.not_found'
        defaultMessage='This post cannot be displayed.'
      />
    );
  }

  if (quoteError) {
    return <QuoteWrapper isError>{quoteError}</QuoteWrapper>;
  }

  return (
    <QuoteWrapper>
      <StatusContainer
        // @ts-expect-error Status isn't typed yet
        isQuotedPost
        id={quotedStatusId}
        avatarSize={40}
      />
    </QuoteWrapper>
  );
};

interface StatusQuoteManagerProps {
  id: string;
  [key: string]: unknown;
}

/**
 * This wrapper component takes a status ID and, if the associated status
 * is a quote post, it renders the quote into `StatusContainer` as a child.
 * It passes all other props through to `StatusContainer`.
 */

export const StatusQuoteManager = (props: StatusQuoteManagerProps) => {
  const status = useAppSelector((state) => state.statuses.get(props.id));
  const quote = status?.get('quote') as QuoteMap | undefined;

  if (quote) {
    return (
      <StatusContainer {...props}>
        <QuotedStatus quote={quote} />
      </StatusContainer>
    );
  }

  return <StatusContainer {...props} />;
};
