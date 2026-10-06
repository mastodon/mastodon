import type React from 'react';
import { useCallback } from 'react';

import { quoteComposeCancel } from '@/mastodon/actions/compose_typed';
import { QuotedStatus } from '@/mastodon/components/status/quote';
import { useAppDispatch } from '@/mastodon/store';

export const ComposeQuote: React.FC<{ id: string }> = ({ id }) => {
  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    dispatch(quoteComposeCancel());
  }, [dispatch]);

  return <QuotedStatus id={id} clamp onDelete={handleDelete} />;
};
