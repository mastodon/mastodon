import { useEffect } from 'react';

import { fetchAccount } from '../actions/accounts';
import { fetchStatus } from '../actions/statuses';
import { selectPlainAccount } from '../selectors/accounts';
import {
  selectAccountStatus,
  selectExpandedStatus,
  selectPlainStatus,
} from '../selectors/statuses';
import { useAppDispatch, useAppSelector } from '../store';

type IdType = string | null | undefined;
type FetchArg = boolean | 'force';

export function useStatus(id: IdType, fetch: FetchArg = false) {
  const status = useAppSelector((state) => selectPlainStatus(state, id));

  useStatusFetch(fetch && id, { force: fetch === 'force' });

  return status;
}

/** Gets status with full account information, fetching missing data if enabled. */
export function useAccountStatus(id: IdType, fetch: FetchArg = false) {
  const status = useAppSelector((state) => selectAccountStatus(state, id));

  useStatusFetch(fetch && id, { withAccount: true, force: fetch === 'force' });

  return status;
}

/** Adds reblog status and account information to standard Status */
export function useExpandedStatus(id: IdType, fetch: FetchArg = false) {
  const status = useAppSelector((state) =>
    selectExpandedStatus(state, id ?? undefined),
  );

  useStatusFetch(fetch && id, {
    withAccount: true,
    withReblog: true,
    force: fetch === 'force',
  });

  return status;
}

export function useStatusFetch(
  id: IdType | false,
  {
    withAccount,
    withReblog,
    force: forceFetch,
  }: { withAccount?: boolean; withReblog?: boolean; force?: boolean } = {},
) {
  const status = useAppSelector((state) =>
    selectPlainStatus(state, id || null),
  );
  const account = useAppSelector((state) =>
    selectPlainAccount(state, status?.account),
  );
  const reblog = useAppSelector((state) =>
    selectPlainStatus(state, status?.reblog),
  );
  const dispatch = useAppDispatch();

  useEffect(() => {
    if (!id) {
      return;
    }
    if (!status) {
      dispatch(fetchStatus(id, { forceFetch }));
    } else if (withAccount && status.account && !account) {
      dispatch(fetchAccount(status.account));
    } else if (withReblog && status.reblog && !reblog) {
      dispatch(fetchStatus(status.reblog, { forceFetch }));
    }
  }, [
    account,
    dispatch,
    forceFetch,
    id,
    reblog,
    status,
    withAccount,
    withReblog,
  ]);
}
