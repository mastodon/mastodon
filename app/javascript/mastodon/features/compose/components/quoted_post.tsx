import { useMemo } from 'react';
import type { FC } from 'react';

import { Map } from 'immutable';

import { QuotedStatus } from '@/mastodon/components/status_quoted';
import { useAppSelector } from '@/mastodon/store';

export const ComposeQuotedStatus: FC = () => {
  const quotedStatusId = useAppSelector(
    (state) => state.compose.get('quoted_status_id') as string | null,
  );
  const quote = useMemo(
    () =>
      quotedStatusId
        ? Map<'state' | 'quoted_status', string>([
            ['state', 'accepted'],
            ['quoted_status', quotedStatusId],
          ])
        : null,
    [quotedStatusId],
  );
  if (!quote) {
    return null;
  }
  return <QuotedStatus quote={quote} contextType='compose' />;
};
