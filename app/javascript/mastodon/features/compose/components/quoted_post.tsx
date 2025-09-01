import { useCallback, useMemo } from 'react';
import type { FC } from 'react';

import { Map } from 'immutable';

import { quoteComposeCancel } from '@/mastodon/actions/compose_typed';
import { QuotedStatus } from '@/mastodon/components/status_quoted';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

export const ComposeQuotedStatus: FC = () => {
  const quotedStatusId = useAppSelector(
    (state) => state.compose.get('quoted_status_id') as string | null,
  );
  const isEditing = useAppSelector((state) => !!state.compose.get('id'));
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
  const dispatch = useAppDispatch();
  const handleQuoteCancel = useCallback(() => {
    dispatch(quoteComposeCancel());
  }, [dispatch]);
  if (!quote) {
    return null;
  }
  return (
    <QuotedStatus
      quote={quote}
      onQuoteCancel={!isEditing ? handleQuoteCancel : undefined}
    />
  );
};
