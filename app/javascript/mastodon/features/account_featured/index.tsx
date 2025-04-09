import { useEffect } from 'react';

import { useParams } from 'react-router';

import { fetchAccount, lookupAccount } from 'mastodon/actions/accounts';
import { ColumnBackButton } from 'mastodon/components/column_back_button';
import { normalizeForLookup } from 'mastodon/reducers/accounts_map';
import { getAccountHidden } from 'mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { AccountHeader } from '../account_timeline/components/account_header';
import Column from '../ui/components/column';

import { EmptyMessage } from './components/empty_message';

interface Params {
  acct?: string;
  id?: string;
}

function useAccountVisibility(accountId?: string) {
  const blockedBy = useAppSelector(
    (state) => !!state.relationships.getIn([accountId, 'blocked_by'], false),
  );
  const suspended = useAppSelector(
    (state) => !!state.accounts.getIn([accountId, 'suspended'], false),
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

const AccountFeatured = () => {
  const { acct, id } = useParams<Params>();
  const accountId = useAppSelector(
    (state) =>
      id ??
      (state.accounts_map.get(normalizeForLookup(acct)) as string | undefined),
  );
  const dispatch = useAppDispatch();

  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );
  const isAccount = !!account;

  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);
  const forceEmptyState = suspended || blockedBy || hidden;

  useEffect(() => {
    if (!accountId) {
      dispatch(lookupAccount(acct));
    } else if (!isAccount) {
      dispatch(fetchAccount(accountId));
    }
  }, [dispatch, accountId, acct, isAccount]);

  return (
    <Column>
      <ColumnBackButton />

      <div className='scrollable scrollable--flex'>
        {accountId && (
          <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
        )}
        <EmptyMessage
          blockedBy={blockedBy}
          hidden={hidden}
          suspended={suspended}
          accountId={accountId}
        />
      </div>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountFeatured;
