import { FormattedMessage } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import StatusContainer from 'mastodon/containers/status_container';
import { useAppSelector } from 'mastodon/store';

type QuoteMap = ImmutableMap<'state' | 'quoted_status', string | null>;

export const QuotedStatus: React.FC<{ quote: QuoteMap }> = ({ quote }) => {
  const quotedStatusId = quote.get('quoted_status');
  const state = quote.get('state');
  const status = useAppSelector((state) =>
    quotedStatusId ? state.statuses.get(quotedStatusId) : undefined,
  );

  if (!status || !quotedStatusId) {
    return (
      <FormattedMessage id='' defaultMessage='This post cannot be displayed.' />
    );
  } else if (state === 'deleted') {
    return (
      <FormattedMessage
        id=''
        defaultMessage='This post was removed by its author.'
      />
    );
  } else if (state === 'unauthorized') {
    return (
      <FormattedMessage
        id=''
        defaultMessage='This post cannot be displayed as you are not authorized to view it.'
      />
    );
  } else if (state === 'pending') {
    return (
      <FormattedMessage
        id=''
        defaultMessage='This post is pending approval from the original author.'
      />
    );
  } else if (state === 'rejected' || state === 'revoked') {
    return (
      <FormattedMessage
        id=''
        defaultMessage='This post cannot be displayed as the original author does not allow it to be quoted.'
      />
    );
  }

  return (
    <StatusContainer
      // @ts-expect-error Status isn't typed yet
      showActionBar={false}
      id={quotedStatusId}
      avatarSize={40}
    />
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
        <div className='status__quote'>
          <QuotedStatus quote={quote} />
        </div>
      </StatusContainer>
    );
  }

  return <StatusContainer {...props} />;
};
