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

export function useStatus(id: IdType, fetch = false) {
  const status = useAppSelector((state) => selectPlainStatus(state, id));

  useStatusFetch(fetch && id);

  return status;
}

/** Gets status with full account information, fetching missing data if enabled. */
export function useAccountStatus(id: IdType, fetch = false) {
  const status = useAppSelector((state) => selectAccountStatus(state, id));

  useStatusFetch(fetch && id, { withAccount: true });

  return status;
}

/** Adds reblog status and account information to standard Status */
export function useExpandedStatus(id: IdType, fetch = false) {
  const status = useAppSelector((state) =>
    selectExpandedStatus(state, id ?? undefined),
  );

  useStatusFetch(fetch && id, { withAccount: true, withReblog: true });

  return status;
}

export function useStatusFetch(
  id: IdType | false,
  {
    withAccount,
    withReblog,
  }: { withAccount?: boolean; withReblog?: boolean } = {},
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
      dispatch(fetchStatus(id));
    } else if (withAccount && status.account && !account) {
      dispatch(fetchAccount(status.account));
    } else if (withReblog && status.reblog && !reblog) {
      dispatch(fetchStatus(status.reblog));
    }
  }, [account, dispatch, id, reblog, status, withAccount, withReblog]);
}
