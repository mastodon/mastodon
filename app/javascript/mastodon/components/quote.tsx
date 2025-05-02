import { FormattedMessage } from 'react-intl';

import { Map as ImmutableMap } from 'immutable';

import { useAppSelector } from 'mastodon/store';
import { EmbeddedStatus } from 'mastodon/features/notifications_v2/components/embedded_status';

type QuoteMap = ImmutableMap<'state' | 'quoted_status', string | null>;

export const Quote: React.FC<{ quote: QuoteMap }> = ({ quote }) => {
  const quotedStatusId = quote.get('quoted_status');
  const state = quote.get('state');
  const status = useAppSelector((state) =>
    quotedStatusId ? state.statuses.get(quotedStatusId) : undefined,
  );
  const accountId = status?.get('account') as string | undefined;
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );

  if (!status || !quotedStatusId) {
    return (
      <div className='status__quote'>
        <FormattedMessage
          id=''
          defaultMessage='This post cannot be displayed.'
        />
      </div>
    );
  } else if (state === 'deleted') {
    return (
      <div className='status__quote'>
        <FormattedMessage
          id=''
          defaultMessage='This post was removed by its author.'
        />
      </div>
    );
  } else if (state === 'unauthorized') {
    return (
      <div className='status__quote'>
        <FormattedMessage
          id=''
          defaultMessage='This post cannot be displayed as you are not authorized to view it.'
        />
      </div>
    );
  } else if (state === 'pending') {
    return (
      <div className='status__quote'>
        <FormattedMessage
          id=''
          defaultMessage='This post is pending approval from the original author.'
        />
      </div>
    );
  } else if (state === 'rejected' || state === 'revoked') {
    return (
      <div className='status__quote'>
        <FormattedMessage
          id=''
          defaultMessage='This post cannot be displayed as the original author does not allow it to be quoted.'
        />
      </div>
    );
  }

  return (
    <div className='status__quote'>
      <EmbeddedStatus statusId={quotedStatusId} />
    </div>
  );
};
