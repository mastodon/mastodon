import { getAccountHidden } from 'mastodon/selectors/accounts';
import { useAppSelector } from 'mastodon/store';

export function useAccountVisibility(accountId?: string | null) {
  const blockedBy = useAppSelector((state) =>
    accountId
      ? !!state.relationships.getIn([accountId, 'blocked_by'], false)
      : false,
  );
  const suspended = useAppSelector((state) =>
    accountId ? !!state.accounts.getIn([accountId, 'suspended'], false) : false,
  );
  const hidden = useAppSelector((state) =>
    accountId ? Boolean(getAccountHidden(state, accountId)) : false,
  );

  return {
    blockedBy,
    suspended,
    hidden,
  };
}
