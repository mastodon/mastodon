import { useCallback } from 'react';
import type { FC } from 'react';

import { setComposeQuotePolicy } from '@/mastodon/actions/compose_typed';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';

import QuotePolicyDropdown from './quote_policy_dropdown';

interface QuotePolicyButtonProps {
  disabled?: boolean;
}

export const QuotePolicyButton: FC<QuotePolicyButtonProps> = ({
  disabled = false,
}) => {
  const dispatch = useAppDispatch();

  const quotePolicy = useAppSelector(
    (state) => state.compose.get('quote_policy') as ApiQuotePolicy,
  );

  const handleChange = useCallback(
    (newQuotePolicy: ApiQuotePolicy) => {
      dispatch(setComposeQuotePolicy(newQuotePolicy));
    },
    [dispatch],
  );

  return (
    <QuotePolicyDropdown
      value={quotePolicy}
      onChange={handleChange}
      disabled={disabled}
    />
  );
};
